#ifndef SEARCHER_H
#define SEARCHER_H
#include <Python.h>
#include <string>
#include <vector>
#include <sstream>

static std::vector<std::string> Split(const std::string &line);
static bool FileExists(const std::string &file_name);
static void ParseTokens(
    const std::vector<std::string> &tokens,
    int indent,
    std::string &filename,
    std::string &content);
static void Parse(
    FILE *result,
    int indent,
    std::ostringstream &text,
    std::vector<int> &index,
    std::vector<std::string> &files);
static PyObject *Search(PyObject *self, PyObject *args);
#endif

