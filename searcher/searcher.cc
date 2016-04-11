#include "searcher.h"
#include <Python.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <sstream>
#include <regex>
#include <vector>

#if _WIN32
#define POPEN _popen
#define PCLOSE _pclose
#else
#define POPEN popen
#define PCLOSE pclose
#endif

static std::vector<std::string> Split(const std::string &line) {
  std::vector<std::string> tokens;
  std::regex pattern("([-:]\\d+[-:])");
  std::sregex_token_iterator iter(line.begin(), line.end(), pattern, {-1, 0});
  std::sregex_token_iterator end;
  for (; iter != end; ++ iter) {
    tokens.push_back(*iter);
  }
  return tokens;
}

static bool FileExists(const std::string &filename) {
  FILE *file = fopen(filename.c_str(), "r");
  bool exists = (file != NULL);
  if (file) {
    fclose(file);
    file = NULL;
  }
  return exists;
}

static void ParseTokens(
    const std::vector<std::string> &tokens,
    int indent,
    std::string &filename,
    std::string &content) {
  std::ostringstream filename_stream, content_stream;
  if (tokens.size() == 3) {
    filename = tokens[0];
    content_stream << tokens[1].substr(1);
    for (int i = 0; i < indent; ++ i) content_stream << ' ';
    content_stream << tokens[2];
    content = content_stream.str();
  } else {
    size_t i = 0;
    filename_stream << tokens[i];
    while (!FileExists(filename_stream.str()) && i < tokens.size()) {
      filename_stream << tokens[i + 1] << tokens[i + 2];
      i += 2;
    }
    ++ i;
    if (i < tokens.size() - 1) {
      content_stream << tokens[i].substr(1);
      for (int j = 0; j < indent; ++ j) content_stream << ' ';
      for (size_t j = i + 1; j < tokens.size(); ++ j)
      content_stream << tokens[j];
      goto out;
    }
out:
    filename = filename_stream.str();
    content = content_stream.str();
  }
}

static void Parse(
    FILE *result,
    int indent,
    std::ostringstream &text,
    std::vector<int> &index,
    std::vector<std::string> &files) {
  char buffer[4096];
  index.push_back(0);
  while (fgets(buffer, sizeof(buffer), result)) {
    std::ostringstream line_stream;
    line_stream << buffer;
    while (buffer[strlen(buffer) - 1] != '\n') {
      if (!fgets(buffer, sizeof(buffer), result)) break;
      line_stream << buffer;
    }
    std::vector<std::string> tokens = Split(line_stream.str());
    if (tokens.size() != 1) {
      std::string filename, content;
      ParseTokens(tokens, indent, filename, content);
      if (files.size() == 0 || *files.rbegin() != filename) {
        if (files.size() != 0) {
          text << "\n";
          index.push_back(files.size() - 1);
        }
        files.push_back(filename);
        text << filename << "\n";
        index.push_back(files.size() - 1);
      }
      text << content;
      index.push_back(files.size() - 1);
    } else {
      text << tokens[0];
      index.push_back(files.size() - 1);
    }
  }
}

static PyObject *Search(PyObject *self, PyObject *args) {
  const char *cmd;
  int indent = 2;
  if (!PyArg_ParseTuple(args, "s|i", &cmd, &indent)) return NULL;

  std::ostringstream text;
  std::vector<std::string> files;
  std::vector<int> index;
  PyObject *py_text = NULL, *py_index = NULL, *py_files = NULL;
  PyObject *py_result = NULL;

  FILE *result = POPEN(cmd, "r");
  if (result == NULL) goto out;

  Parse(result, indent, text, index, files);

  py_text = Py_BuildValue("s", text.str().c_str());
  py_files = PyList_New(files.size());
  for (size_t i = 0; i < files.size(); ++ i)
    PyList_SetItem(py_files, i, Py_BuildValue("s", files[i].c_str()));
  py_index = PyDict_New();
  for (size_t i = 1; i < index.size(); ++ i)
    PyDict_SetItem(
        py_index, Py_BuildValue("i", i), Py_BuildValue("i", index[i]));
  py_result = PyTuple_Pack(3, py_text, py_index, py_files);
out:
  PCLOSE(result);
  result = NULL;
  if (py_result)
    return py_result;
  else
    return PyTuple_Pack(
      3, Py_BuildValue("s", ""), PyDict_New(), PyList_New(0));
}

static PyMethodDef searcherMethods[] = {
  {"search", Search, METH_KEYWORDS, "call searcher and parse the result"},
  {NULL, NULL, 0, NULL},
};

PyMODINIT_FUNC
initsearcher(void) {
  (void)Py_InitModule("searcher", searcherMethods);
}

