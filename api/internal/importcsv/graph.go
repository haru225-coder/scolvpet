package importcsv

func cycleNodes(graph map[string][]string) map[string]bool {
	const (
		unvisited = iota
		visiting
		visited
	)
	colors := make(map[string]int, len(graph))
	stack := make([]string, 0, len(graph))
	stackIndexes := make(map[string]int, len(graph))
	cycles := make(map[string]bool)
	var visit func(string)
	visit = func(node string) {
		switch colors[node] {
		case visiting:
			start := stackIndexes[node]
			for _, cycleNode := range stack[start:] {
				cycles[cycleNode] = true
			}
			return
		case visited:
			return
		}
		colors[node] = visiting
		stackIndexes[node] = len(stack)
		stack = append(stack, node)
		for _, parent := range graph[node] {
			visit(parent)
		}
		stack = stack[:len(stack)-1]
		delete(stackIndexes, node)
		colors[node] = visited
	}
	for node := range graph {
		visit(node)
	}
	return cycles
}
