#!/usr/bin/env python3
"""
OTel Session Overview
Parses OpenTelemetry Collector debug output and displays a summary
organized by demo area.

Usage:
  # From a running collector (piped):
  docker logs <container_id> 2>&1 | python3 scripts/otel_session_overview.py

  # From a saved log file:
  python3 scripts/otel_session_overview.py collector_output.log
"""

import re
import sys
from datetime import datetime
from collections import defaultdict

FMT = "%Y-%m-%d %H:%M:%S.%f +0000 UTC"

# Map span name prefixes/patterns to demo categories
SPAN_CATEGORIES = [
    ("Tracing Demo", re.compile(r"^demo\.(single_span|parent_operation|child_step_|operation_with_events|status_)")),
    ("Error Types Demo", re.compile(r"^demo\.(sync_error|async_error|flutter_error|error_with_context)")),
    ("Context Propagation", re.compile(r"^(async_chain|correct_callback_chain|process[ABC]_no_parent|isolate_parent|isolate_work|http\.client\.request)")),
    ("Sampling Demo", re.compile(r"^sampling\.")),
    ("Baggage Demo", re.compile(r"^baggage\.")),
    ("Interaction Tracking", re.compile(r"^ui\.")),
    ("Lifecycle", re.compile(r"^app\.(cold_start|warm_start|lifecycle_change|foreground_session)")),
    ("Navigation", re.compile(r"^navigation\.")),
    ("Performance", re.compile(r"^app\.jank_simulation")),
]

METRIC_CATEGORIES = [
    ("Metrics Demo", re.compile(r"^demo\.(button_clicks|categorized_actions|active_items|response_time)")),
    ("Metrics Demo", re.compile(r"^flutter\.frame\.duration")),
    ("Performance", re.compile(r"^app\.(jank_frames|frame_duration|frame_build_time|frame_raster_time|frame_total_time)")),
    ("Lifecycle", re.compile(r"^app\.(lifecycle_transitions|foreground_session_duration|background_duration|session_duration)")),
]


def categorize_span(name):
    for category, pattern in SPAN_CATEGORIES:
        if pattern.search(name):
            return category
    return "Other"


def categorize_metric(name):
    for category, pattern in METRIC_CATEGORIES:
        if pattern.search(name):
            return category
    return "Other"


def parse_duration_ms(start_str, end_str):
    try:
        s = datetime.strptime(start_str, FMT)
        e = datetime.strptime(end_str, FMT)
        return (e - s).total_seconds() * 1000
    except ValueError:
        return None


def parse_collector_output(content):
    spans = []
    metrics = defaultdict(dict)

    # --- Parse spans ---
    name = start = end = status = trace_id = parent_id = None
    in_span = False

    for line in content.splitlines():
        stripped = line.strip()

        if stripped.startswith("Span #"):
            # Save previous span if complete
            if in_span and name and start and end:
                spans.append({
                    "name": name,
                    "start": start,
                    "end": end,
                    "duration_ms": parse_duration_ms(start, end),
                    "status": status,
                    "trace_id": trace_id,
                    "parent_id": parent_id,
                })
            in_span = True
            name = start = end = status = trace_id = parent_id = None
            continue

        if in_span:
            m = re.search(r"Name\s*:\s*(.+)", stripped)
            if m:
                name = m.group(1).strip()
            m = re.search(r"Start time\s*:\s*(.+)", stripped)
            if m:
                start = m.group(1).strip()
            m = re.search(r"End time\s*:\s*(.+)", stripped)
            if m:
                end = m.group(1).strip()
            m = re.search(r"Status code\s*:\s*(.+)", stripped)
            if m:
                status = m.group(1).strip()
            m = re.search(r"Trace ID\s*:\s*(.+)", stripped)
            if m:
                trace_id = m.group(1).strip()
            m = re.search(r"Parent ID\s*:\s*(.+)", stripped)
            if m:
                parent_id = m.group(1).strip()

        # Detect end of span block (next section or blank)
        if in_span and (stripped.startswith("Resource") or stripped.startswith("Metric #") or stripped.startswith("{")):
            if name and start and end:
                spans.append({
                    "name": name,
                    "start": start,
                    "end": end,
                    "duration_ms": parse_duration_ms(start, end),
                    "status": status,
                    "trace_id": trace_id,
                    "parent_id": parent_id,
                })
            in_span = False
            name = start = end = status = trace_id = parent_id = None

    # Don't forget last span
    if in_span and name and start and end:
        spans.append({
            "name": name,
            "start": start,
            "end": end,
            "duration_ms": parse_duration_ms(start, end),
            "status": status,
            "trace_id": trace_id,
            "parent_id": parent_id,
        })

    # --- Parse metrics (latest values only) ---
    current_metric_name = None
    current_metric_type = None
    for line in content.splitlines():
        stripped = line.strip()
        m = re.match(r"-> Name:\s*(.+)", stripped)
        if m:
            current_metric_name = m.group(1).strip()
        m = re.match(r"-> DataType:\s*(.+)", stripped)
        if m:
            current_metric_type = m.group(1).strip()

        if current_metric_name:
            m = re.match(r"Count:\s*(\d+)", stripped)
            if m:
                metrics[current_metric_name]["count"] = int(m.group(1))
                metrics[current_metric_name]["type"] = current_metric_type

            m = re.match(r"Sum:\s*([\d.]+)", stripped)
            if m:
                metrics[current_metric_name]["sum"] = float(m.group(1))

            m = re.match(r"Value:\s*([\d.]+)", stripped)
            if m:
                metrics[current_metric_name]["value"] = float(m.group(1))

            m = re.match(r"-> Unit:\s*(.+)", stripped)
            if m:
                metrics[current_metric_name]["unit"] = m.group(1).strip()

    return spans, dict(metrics)


def print_header(title):
    print(f"\n{'=' * 64}")
    print(f"  {title}")
    print(f"{'=' * 64}")


def print_section(title):
    print(f"\n  --- {title} ---")


def format_duration(ms):
    if ms is None:
        return "N/A"
    if ms < 1:
        return f"{ms * 1000:.0f} us"
    if ms < 1000:
        return f"{ms:.2f} ms"
    return f"{ms / 1000:.2f} s"


def main():
    if len(sys.argv) > 1:
        with open(sys.argv[1]) as f:
            content = f.read()
    else:
        content = sys.stdin.read()

    spans, metrics = parse_collector_output(content)

    # Session time range
    all_times = []
    for s in spans:
        try:
            all_times.append(datetime.strptime(s["start"], FMT))
            all_times.append(datetime.strptime(s["end"], FMT))
        except ValueError:
            pass

    print_header("OTel Session Overview")

    if all_times:
        earliest = min(all_times)
        latest = max(all_times)
        duration = latest - earliest
        print(f"  Session start : {earliest.strftime('%Y-%m-%d %H:%M:%S UTC')}")
        print(f"  Session end   : {latest.strftime('%Y-%m-%d %H:%M:%S UTC')}")
        print(f"  Duration      : {duration}")
    print(f"  Total spans   : {len(spans)}")
    print(f"  Total metrics : {len(metrics)}")

    # --- Spans by category ---
    print_header("Spans by Demo")

    categorized = defaultdict(list)
    for s in spans:
        cat = categorize_span(s["name"])
        categorized[cat].append(s)

    # Print in defined order, then "Other"
    seen = set()
    ordered_cats = [name for name, _ in SPAN_CATEGORIES] + ["Other"]
    for cat in ordered_cats:
        if cat in seen or cat not in categorized:
            continue
        seen.add(cat)
        cat_spans = categorized[cat]
        print_section(f"{cat} ({len(cat_spans)} spans)")

        # Group by span name
        by_name = defaultdict(list)
        for s in cat_spans:
            by_name[s["name"]].append(s)

        for span_name in sorted(by_name.keys()):
            group = by_name[span_name]
            durations = [s["duration_ms"] for s in group if s["duration_ms"] is not None]
            statuses = [s["status"] for s in group if s["status"]]

            count = len(group)
            if durations:
                avg = sum(durations) / len(durations)
                mn = min(durations)
                mx = max(durations)
                if count == 1:
                    dur_str = format_duration(durations[0])
                else:
                    dur_str = f"avg={format_duration(avg)}, min={format_duration(mn)}, max={format_duration(mx)}"
            else:
                dur_str = "N/A"

            status_summary = ""
            if statuses:
                error_count = sum(1 for st in statuses if st and st.lower() == "error")
                if error_count > 0:
                    status_summary = f" [errors: {error_count}/{count}]"

            print(f"    {span_name:<42} x{count:>3}  {dur_str}{status_summary}")

    # --- Metrics by category ---
    print_header("Metrics by Demo")

    metric_categorized = defaultdict(dict)
    for name, data in metrics.items():
        cat = categorize_metric(name)
        metric_categorized[cat][name] = data

    seen = set()
    ordered_metric_cats = [name for name, _ in METRIC_CATEGORIES] + ["Other"]
    for cat in ordered_metric_cats:
        if cat in seen or cat not in metric_categorized:
            continue
        seen.add(cat)
        cat_metrics = metric_categorized[cat]
        print_section(f"{cat} ({len(cat_metrics)} metrics)")

        for name in sorted(cat_metrics.keys()):
            data = cat_metrics[name]
            dtype = data.get("type", "?")
            unit = data.get("unit", "")

            parts = [f"type={dtype}"]
            if "count" in data:
                parts.append(f"count={data['count']}")
            if "sum" in data:
                parts.append(f"sum={data['sum']:.2f}")
            if "value" in data:
                parts.append(f"value={data['value']:.0f}")
            if unit:
                parts.append(f"unit={unit}")

            print(f"    {name:<42} {', '.join(parts)}")

    # --- Trace topology ---
    if spans:
        print_header("Trace Summary")
        traces = defaultdict(list)
        for s in spans:
            if s["trace_id"]:
                traces[s["trace_id"]].append(s)

        for tid, trace_spans in sorted(traces.items(), key=lambda x: len(x[1]), reverse=True):
            roots = [s for s in trace_spans if not s["parent_id"]]
            root_names = ", ".join(s["name"] for s in roots) if roots else "(no root)"
            print(f"    Trace {tid[:16]}...  {len(trace_spans)} spans  root: {root_names}")

    print(f"\n{'=' * 64}\n")


if __name__ == "__main__":
    main()
