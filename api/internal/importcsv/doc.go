// Package importcsv implements the I2 CSV detection, preflight and atomic commit workflow.
//
// The PostgreSQL adapter deliberately keeps object storage outside this package. Its local
// workflow accepts CSV bytes from the caller, persists the file hash and a local-bytes object
// key, then stores import_job/import_row/import_issue state and applies the commit plan. The
// HTTP layer may replace that byte source with an uploaded object without changing the engine.
package importcsv
