#!/usr/bin/env python3
"""
Tech Tree Visualizer for PSP Game
Reads tech tree and parts catalog TSV files and generates a visual graph.
"""

import csv
from graphviz import Digraph
import html
import urllib.request
from io import StringIO


# Google Sheets published URLs (from googleSheetData.ms)
BASE_URL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vRA2AQx4X9PZyyoU5mMV18MdB-OI50dx-AdShkBqMKqSaa8dFhb3USE5vtUF1JlPBjkTZFouuyF3Quj/pub?output=tsv"
PARTS_LIST_URL = BASE_URL + "&gid=22599298"
TECH_TREE_URL = BASE_URL + "&gid=1681045610"


def fetch_tsv_from_url(url):
    """Fetch TSV data from a URL and return it as a string."""
    with urllib.request.urlopen(url) as response:
        return response.read().decode('utf-8')


def read_tech_tree(data_source):
    """Read the tech tree TSV data and return a dict of tech nodes.

    Args:
        data_source: Either a filename (str) or TSV data string
    """
    tech_nodes = {}

    # Check if data_source is a URL
    if data_source.startswith('http://') or data_source.startswith('https://'):
        tsv_data = fetch_tsv_from_url(data_source)
        reader = csv.DictReader(StringIO(tsv_data), delimiter='\t')
    else:
        # Try to open as file, if that fails assume it's TSV data
        try:
            f = open(data_source, 'r', encoding='utf-8')
            reader = csv.DictReader(f, delimiter='\t')
        except FileNotFoundError:
            reader = csv.DictReader(StringIO(data_source), delimiter='\t')
            f = None

    try:
        for row in reader:
            node_name = row['Node']
            tech_nodes[node_name] = {
                'tier': int(row['Tier']),
                'description': row['Description'],
                'prerequisites': [p.strip() for p in row['Prerequisites'].split(',') if p.strip()],
                'parts': []
            }
    finally:
        if 'f' in locals() and f is not None:
            f.close()

    return tech_nodes


def read_parts_catalog(data_source):
    """Read the parts catalog TSV data and return a list of parts.

    Args:
        data_source: Either a filename (str) or TSV data string
    """
    parts = []

    # Check if data_source is a URL
    if data_source.startswith('http://') or data_source.startswith('https://'):
        tsv_data = fetch_tsv_from_url(data_source)
        reader = csv.DictReader(StringIO(tsv_data), delimiter='\t')
    else:
        # Try to open as file, if that fails assume it's TSV data
        try:
            f = open(data_source, 'r', encoding='utf-8')
            reader = csv.DictReader(f, delimiter='\t')
        except FileNotFoundError:
            reader = csv.DictReader(StringIO(data_source), delimiter='\t')
            f = None

    try:
        for row in reader:
            parts.append({
                'category': row['Category'],
                'name': row['Name'],
                'tech_node': row['Tech Node'].strip() if row['Tech Node'] else None,
                'size': row['Size']
            })
    finally:
        if 'f' in locals() and f is not None:
            f.close()

    return parts


def assign_parts_to_nodes(tech_nodes, parts):
    """Assign parts to their corresponding tech nodes."""
    unassigned_parts = []

    for part in parts:
        if part['tech_node'] and part['tech_node'] in tech_nodes:
            tech_nodes[part['tech_node']]['parts'].append(part)
        else:
            unassigned_parts.append(part)

    return unassigned_parts


def create_tech_tree_graph(tech_nodes, unassigned_parts):
    """Create a graphviz visualization of the tech tree."""
    dot = Digraph(comment='Tech Tree', format='png')
    dot.attr(rankdir='TB', ranksep='1.0', nodesep='0.5')
    dot.attr('node', shape='box', style='rounded,filled', fillcolor='lightblue', fontname='Arial')
    dot.attr('edge', color='darkblue', arrowsize='0.8')

    # Create all tech nodes (let graphviz arrange them based on prerequisites)
    for node_name, node_data in tech_nodes.items():
        # Build the label with node name and parts
        label = f'<B>{html.escape(node_name)}</B>'

        if node_data['parts']:
            label += '<BR/><FONT POINT-SIZE="9">'
            for part in node_data['parts']:
                part_name = html.escape(part["name"])
                part_size = html.escape(part["size"]) if part["size"] else ""
                label += f'<BR/>  • {part_name}'
                if part_size:
                    label += f" ({part_size})"
            label += '</FONT>'

        label = f'<{label}>'

        dot.node(node_name, label=label, fillcolor='lightblue')

    # Add edges for prerequisites
    for node_name, node_data in tech_nodes.items():
        for prereq in node_data['prerequisites']:
            if prereq in tech_nodes:
                dot.edge(prereq, node_name)

    # Add unassigned parts in a separate cluster
    if unassigned_parts:
        with dot.subgraph(name='cluster_unassigned') as c:
            c.attr(label='Unassigned Parts', style='filled', fillcolor='lightyellow')

            # Group unassigned parts by category
            by_category = {}
            for part in unassigned_parts:
                cat = part['category']
                if cat not in by_category:
                    by_category[cat] = []
                by_category[cat].append(part)

            label_parts = []
            for category in sorted(by_category.keys()):
                label_parts.append(f'<B>{html.escape(category)}:</B>')
                for part in by_category[category]:
                    label = f'  • {html.escape(part["name"])}{size_str}'
                    if part['size'].trim():
                        label += f" ({html.escape(part['size'])})"
                    label_parts.append(label)

            label = f'<FONT POINT-SIZE="10">{"<BR/>".join(label_parts)}</FONT>'
            label = f'<{label}>'
            c.node('unassigned', label=label, shape='box', fillcolor='lightyellow')

    return dot


def main():
    # Fetch data from Google Sheets
    print("Fetching tech tree from Google Sheets...")
    tech_nodes = read_tech_tree(TECH_TREE_URL)

    print("Fetching parts catalog from Google Sheets...")
    parts = read_parts_catalog(PARTS_LIST_URL)

    print("Assigning parts to tech nodes...")
    unassigned_parts = assign_parts_to_nodes(tech_nodes, parts)

    print(f"Found {len(tech_nodes)} tech nodes and {len(parts)} parts")
    print(f"{len(unassigned_parts)} parts are unassigned")

    print("Generating visualization...")
    graph = create_tech_tree_graph(tech_nodes, unassigned_parts)

    # Render the graph
    output_file = 'tech_tree'
    graph.render(output_file, cleanup=True)
    print(f"Graph saved as {output_file}.png")

    # Also save the source for inspection
    with open(f'{output_file}.dot', 'w') as f:
        f.write(graph.source)
    print(f"Graph source saved as {output_file}.dot")


if __name__ == '__main__':
    main()
