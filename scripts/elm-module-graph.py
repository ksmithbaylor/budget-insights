#!/usr/bin/python

import argparse
import json
import io
import os
import re
import sys

re_import = re.compile(
    r"{-.*?-}|^import\s+([A-Z][\w\.]*)", re.DOTALL | re.MULTILINE
)


# source text -> [modulename]
def extract_imports(text):
    return filter(
        lambda s: s != "" and s[0:7] != "Native.", re_import.findall(text)
    )


# source text -> modulename
def extract_modulename(text):
    match = re.match(r"(?:port )?module\s+([A-Z][\w\.]*)", text)
    return match.group(1) if match is not None else None


# -> {"sourcedirs": [dir], "dependencies": [packagename]}
def get_sourcedirs(packagedir):
    elmpackagedata = json.load(open(os.path.join(packagedir, "elm.json")))
    return map(
        lambda dir: os.path.normpath(os.path.join(packagedir, dir)),
        elmpackagedata.get("source-directories", [])
    )


def namespace(modulename):
    modulefile = find_module_source_file(modulename)
    if modulefile is None:
        return "external/package {}".format(modulename)
    else:
        return "user/project {}".format(modulename)


# -> (packagename, modulename, sourcepath)
def find_module_source_file(modulename):
    segments = modulename.split(".")
    for sourcedir in get_sourcedirs('.'):
        sourcepath = os.path.join(sourcedir, *segments) + ".elm"
        if os.path.isfile(sourcepath):
            return sourcepath

    return None


# -> {qualifiedmodulename: {"imports": [qualifiedmodulename], "package": packagename}}
def graph_from_imports(modulename, graph):
    if namespace(modulename) in graph:
        return

    modulefile = find_module_source_file(modulename)

    if modulefile is None:
        graph[namespace(modulename)] = {
            'imports': [],
            'package': namespace(modulename).split(' ')[0]
        }
        return

    moduletext = open(modulefile).read()
    if extract_modulename(moduletext) != modulename:
        print "error: module name does not match: {} ({})".format(
            modulename, modulefile
        )
        sys.exit(1)

    imports = extract_imports(moduletext)

    graph[namespace(modulename)] = {
        'imports': map(namespace, imports),
        'package': namespace(modulename).split(' ')[0]
    }

    for module in imports:
        graph_from_imports(module, graph)

    return graph


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-o",
        "--output",
        default="module-graph.json",
        help="file to write to (default: module-graph.json)"
    )
    parser.add_argument("entry", help="name of Elm module to start at")
    args = parser.parse_args()

    entry = args.entry
    filepath = find_module_source_file(entry)

    if not os.path.isfile(filepath):
        print "error: file not found: " + filepath
        sys.exit(1)

    modulegraph = graph_from_imports(entry, {})

    output = io.open(args.output, "w", encoding="utf-8")
    output.write(
        unicode(
            json.dumps(modulegraph, indent=2, separators=[",", ": "]),
            encoding="utf-8-sig"
        )
    )
    output.close()


if __name__ == "__main__":
    main()
