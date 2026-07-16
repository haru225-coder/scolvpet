package importcsv

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
)

type EngineOption func(*Engine)

type Engine struct {
	store Store
	now   func() time.Time
	newID func() string
}

func New(store Store, options ...EngineOption) *Engine {
	engine := &Engine{
		store: store,
		now:   time.Now,
		newID: uuid.NewString,
	}
	for _, option := range options {
		option(engine)
	}
	return engine
}

func WithClock(clock func() time.Time) EngineOption {
	return func(engine *Engine) {
		if clock != nil {
			engine.now = clock
		}
	}
}

func WithIDGenerator(generator func() string) EngineOption {
	return func(engine *Engine) {
		if generator != nil {
			engine.newID = generator
		}
	}
}

func (engine *Engine) Preflight(ctx context.Context, request PreflightRequest) (*PreflightReport, error) {
	if engine.store == nil {
		return nil, errors.New("importcsv: Store 为空")
	}
	if request.OwnerID == "" {
		return nil, errors.New("importcsv: owner_id 为空")
	}
	if request.File == nil {
		return nil, errors.New("importcsv: ParsedFile 为空")
	}
	snapshot, err := engine.store.Snapshot(ctx, request.OwnerID)
	if err != nil {
		return nil, fmt.Errorf("读取 owner 导入快照: %w", err)
	}
	if snapshot.OwnerID != "" && snapshot.OwnerID != request.OwnerID {
		return nil, errors.New("importcsv: Store 返回了其他 owner 的快照")
	}
	if request.OrganizationID == "" {
		request.OrganizationID = snapshot.OrganizationID
	}
	if snapshot.OrganizationID != "" && request.OrganizationID != snapshot.OrganizationID {
		return nil, errors.New("importcsv: organization_id 与 owner 快照不一致")
	}
	request.Options = defaultPreflightOptions(request.Options)
	state, err := newPreflightState(engine, request, snapshot)
	if err != nil {
		return nil, err
	}
	switch request.File.Template {
	case TemplateHamster:
		state.preflightHamsters()
	case TemplateEnclosure:
		state.preflightEnclosures()
	case TemplateWeight:
		state.preflightWeights()
	default:
		return nil, fmt.Errorf("importcsv: 未支持的模板 %q", request.File.Template)
	}
	return state.finish(), nil
}

func defaultPreflightOptions(options PreflightOptions) PreflightOptions {
	if options.Timezone == "" {
		options.Timezone = "Asia/Shanghai"
	}
	if options.HistoricalLitterPolicy == "" {
		options.HistoricalLitterPolicy = HistoricalLitterCreateIfComplete
	}
	if options.ExistingFieldPolicy == "" {
		options.ExistingFieldPolicy = ExistingFieldPreserveNonNull
	}
	return options
}
