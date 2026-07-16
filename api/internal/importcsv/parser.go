package importcsv

import (
	"bytes"
	"crypto/sha256"
	"encoding/csv"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"sort"
	"strings"
	"unicode/utf8"

	"golang.org/x/text/encoding/simplifiedchinese"
	"golang.org/x/text/transform"
)

var (
	ErrEmptyCSV          = errors.New("CSV 内容为空")
	ErrDelimiterNotFound = errors.New("未识别到支持的 CSV 分隔符")
)

func Parse(data []byte, options ParseOptions) (*ParsedFile, error) {
	if len(data) == 0 {
		return nil, ErrEmptyCSV
	}
	digest := sha256.Sum256(data)
	decoded, encoding, err := decodeText(data)
	if err != nil {
		return nil, err
	}
	delimiter, err := detectDelimiter(decoded)
	if err != nil {
		return nil, err
	}
	records, err := readRecords(decoded, delimiter)
	if err != nil {
		return nil, fmt.Errorf("解析 CSV: %w", err)
	}
	if len(records) == 0 || isBlankRecord(records[0]) {
		return nil, ErrEmptyCSV
	}
	headers := make([]string, len(records[0]))
	for index, header := range records[0] {
		headers[index] = strings.TrimSpace(strings.TrimPrefix(header, "\ufeff"))
	}
	kind := options.Template
	if kind == "" {
		kind, err = detectTemplate(headers)
		if err != nil {
			return nil, err
		}
	}
	template, ok := TemplateFor(kind)
	if !ok {
		return nil, fmt.Errorf("未知 CSV 模板 %q", kind)
	}
	candidateMapping, unrecognized := recognizeColumns(headers, template)
	mapping, mappingIssues := resolveMapping(headers, template, candidateMapping, options.Mapping)
	file := &ParsedFile{
		Template:            kind,
		Encoding:            encoding,
		Delimiter:           delimiter,
		Headers:             headers,
		CandidateMapping:    candidateMapping,
		Mapping:             mapping,
		UnrecognizedColumns: unrecognized,
		Issues:              mappingIssues,
		FileSHA256:          hex.EncodeToString(digest[:]),
	}
	for recordIndex, record := range records[1:] {
		if isBlankRecord(record) {
			continue
		}
		rowNumber := recordIndex + 2
		row := ParsedRow{
			RowNumber: rowNumber,
			Raw:       make(map[string]string, len(headers)),
			Mapped:    make(map[string]string, len(mapping)),
		}
		if len(record) != len(headers) {
			row.Issues = append(row.Issues, Issue{
				RowNumber:  rowNumber,
				Code:       "COLUMN_COUNT_MISMATCH",
				Message:    fmt.Sprintf("该行有 %d 列，表头有 %d 列", len(record), len(headers)),
				Severity:   SeverityBlocking,
				Suggestion: "补齐缺失列或移除多余分隔符",
			})
		}
		valuesForHash := make([]string, len(headers))
		for index, header := range headers {
			value := ""
			if index < len(record) {
				value = strings.TrimSpace(record[index])
			}
			valuesForHash[index] = value
			row.Raw[header] = value
			if target, mapped := mapping[header]; mapped {
				row.Mapped[target] = value
			}
		}
		rowDigest := sha256.Sum256([]byte(strings.Join(valuesForHash, "\x1f")))
		row.RowSHA256 = hex.EncodeToString(rowDigest[:])
		file.Rows = append(file.Rows, row)
	}
	return file, nil
}

func decodeText(data []byte) (string, SourceEncoding, error) {
	switch {
	case bytes.HasPrefix(data, []byte{0xef, 0xbb, 0xbf}):
		payload := data[3:]
		if !utf8.Valid(payload) {
			return "", "", errors.New("UTF-8 BOM 后的数据不是有效 UTF-8")
		}
		return string(payload), EncodingUTF8BOM, nil
	case bytes.HasPrefix(data, []byte{0xff, 0xfe}), bytes.HasPrefix(data, []byte{0xfe, 0xff}):
		return "", "", errors.New("识别到 UTF-16 BOM；I2 OpenAPI 仅接受 utf-8、utf-8-bom 或 gb18030")
	case utf8.Valid(data):
		return string(data), EncodingUTF8, nil
	default:
		decoded, _, err := transform.Bytes(simplifiedchinese.GB18030.NewDecoder(), data)
		if err != nil || !utf8.Valid(decoded) {
			return "", "", errors.New("CSV 编码既不是 UTF-8，也不是有效 GB18030")
		}
		return string(decoded), EncodingGB18030, nil
	}
}

func detectDelimiter(content string) (rune, error) {
	type score struct {
		delimiter rune
		value     int
	}
	best := score{value: -1}
	for _, delimiter := range []rune{',', '\t', ';', '|'} {
		records, err := readRecordsLimit(content, delimiter, 24)
		if err != nil || len(records) == 0 {
			continue
		}
		widthCounts := make(map[int]int)
		for _, record := range records {
			if !isBlankRecord(record) {
				widthCounts[len(record)]++
			}
		}
		modeWidth, modeCount := 0, 0
		for width, count := range widthCounts {
			if width > 1 && (count > modeCount || count == modeCount && width > modeWidth) {
				modeWidth, modeCount = width, count
			}
		}
		if modeWidth <= 1 {
			continue
		}
		current := modeCount*100 + modeWidth*10 - (len(records)-modeCount)*25
		if current > best.value {
			best = score{delimiter: delimiter, value: current}
		}
	}
	if best.value < 0 {
		return 0, ErrDelimiterNotFound
	}
	return best.delimiter, nil
}

func readRecords(content string, delimiter rune) ([][]string, error) {
	return readRecordsLimit(content, delimiter, 0)
}

func readRecordsLimit(content string, delimiter rune, limit int) ([][]string, error) {
	reader := csv.NewReader(strings.NewReader(content))
	reader.Comma = delimiter
	reader.FieldsPerRecord = -1
	reader.TrimLeadingSpace = true
	records := make([][]string, 0)
	for limit <= 0 || len(records) < limit {
		record, err := reader.Read()
		if errors.Is(err, io.EOF) {
			break
		}
		if err != nil {
			return nil, err
		}
		records = append(records, record)
	}
	return records, nil
}

func recognizeColumns(headers []string, template Template) (map[string]string, []string) {
	aliases := aliasIndex(template)
	mapping := make(map[string]string)
	unrecognized := make([]string, 0)
	for _, header := range headers {
		if target, ok := aliases[normalizeColumn(header)]; ok {
			mapping[header] = target
		} else {
			unrecognized = append(unrecognized, header)
		}
	}
	return mapping, unrecognized
}

func resolveMapping(headers []string, template Template, candidates, explicit map[string]string) (map[string]string, []Issue) {
	validFields := fieldIndex(template)
	headerSet := make(map[string]struct{}, len(headers))
	for _, header := range headers {
		headerSet[header] = struct{}{}
	}
	result := make(map[string]string, len(candidates))
	for source, target := range candidates {
		result[source] = target
	}
	issues := make([]Issue, 0)
	for source, target := range explicit {
		if _, ok := headerSet[source]; !ok {
			issues = append(issues, Issue{RowNumber: 1, ColumnName: source, Code: "MAPPING_SOURCE_NOT_FOUND", Message: "映射源列不存在", Severity: SeverityBlocking, OriginalValue: source, Suggestion: "选择 CSV 中存在的表头"})
			continue
		}
		if _, ok := validFields[target]; !ok {
			issues = append(issues, Issue{RowNumber: 1, ColumnName: source, Code: "MAPPING_TARGET_INVALID", Message: "映射目标字段不属于当前模板", Severity: SeverityBlocking, OriginalValue: target, Suggestion: "选择当前模板支持的目标字段"})
			continue
		}
		result[source] = target
	}
	targetSources := make(map[string][]string)
	for source, target := range result {
		targetSources[target] = append(targetSources[target], source)
	}
	for target, sources := range targetSources {
		if len(sources) <= 1 {
			continue
		}
		sort.Strings(sources)
		issues = append(issues, Issue{
			RowNumber:     1,
			ColumnName:    strings.Join(sources, ","),
			Code:          "DUPLICATE_TARGET_MAPPING",
			Message:       fmt.Sprintf("多个源列同时映射到 %s", target),
			Severity:      SeverityBlocking,
			OriginalValue: strings.Join(sources, ","),
			Suggestion:    "每个目标字段只保留一个源列",
		})
	}
	return result, issues
}

func isBlankRecord(record []string) bool {
	for _, value := range record {
		if strings.TrimSpace(value) != "" {
			return false
		}
	}
	return true
}
