import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mustache_template/mustache.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _creating = false;

  bool _searchLoading = false;

  /// 是否使用绝对路径
  bool _isAbsolute = false;

  /// 包名是否一致
  bool _isPackageNameSame = true;

  final TextEditingController _packageName = TextEditingController();
  final TextEditingController _basePath = TextEditingController();
  final TextEditingController _entityPath = TextEditingController();
  final TextEditingController _controllerPath = TextEditingController();
  final TextEditingController _controllerPackageName = TextEditingController();
  final TextEditingController _servicePath = TextEditingController();
  final TextEditingController _servicePackageName = TextEditingController();
  final TextEditingController _serviceImplPath = TextEditingController();
  final TextEditingController _serviceImplPackageName = TextEditingController();
  final TextEditingController _repositoryPath = TextEditingController();
  final TextEditingController _repositoryPackageName = TextEditingController();
  final TextEditingController _dtoPath = TextEditingController();
  final TextEditingController _dtoPackageName = TextEditingController();
  final TextEditingController _formPath = TextEditingController();
  final TextEditingController _formPackageName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _creating
          ? const CircularProgressIndicator(
              color: Colors.red,
            )
          : FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () async {
                if (_entityPath.text == '' ||
                    _basePath.text == '' ||
                    _controllerPath.text == '' ||
                    _controllerPackageName.text == '' ||
                    _servicePath.text == '' ||
                    _servicePackageName.text == '' ||
                    _serviceImplPath.text == '' ||
                    _serviceImplPackageName.text == '' ||
                    _repositoryPath.text == '' ||
                    _repositoryPackageName.text == '' ||
                    _dtoPath.text == '' ||
                    _dtoPackageName.text == '' ||
                    _formPath.text == '' ||
                    _formPackageName.text == '') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("提示"),
                        content: const Text("请填写所有输入框？"),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("确定")),
                        ],
                      );
                    },
                  );
                  return;
                }

                Stream<FileSystemEntity> fileList = Directory(_isAbsolute
                        ? _entityPath.text
                        : (_basePath.text + _entityPath.text))
                    .list();
                await for (FileSystemEntity fileSystemEntity in fileList) {
                  String path = fileSystemEntity.path;
                  if (!(path.endsWith(".java"))) {
                    continue;
                  }
                  var entityNameArray = path.split("/");
                  var entityName = entityNameArray[entityNameArray.length - 1];
                  entityNameArray = entityName.split(".");
                  entityName = entityNameArray[0];

                  String substring = entityName.substring(0, 1);
                  String entityNameLow = entityName.replaceFirst(
                      substring, substring.toLowerCase());

                  _createControllerFile(entityName, entityNameLow);
                  _createServiceFile(entityName, entityNameLow);
                  _createServiceImplFile(entityName, entityNameLow);
                  _createRepositoryFile(entityName, entityNameLow);
                  _createDtoFile(entityName, entityNameLow);
                  _createFormFile(entityName, entityNameLow);
                }

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("提示"),
                      content: const Text("操作成功"),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("确定")),
                      ],
                    );
                  },
                );
              },
              child: const Icon(Icons.play_arrow),
            ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: TextField(
                        controller: _packageName,
                        onChanged: (String value) {
                          if (_packageName.text != '' && _isPackageNameSame) {
                            _controllerPackageName.text = _packageName.text;
                            _servicePackageName.text = _packageName.text;
                            _serviceImplPackageName.text = _packageName.text;
                            _repositoryPackageName.text = _packageName.text;
                            _dtoPackageName.text = _packageName.text;
                            _formPackageName.text = _packageName.text;
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "包名",
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('是否使用绝对路径'),
                              Switch(
                                value: _isAbsolute,
                                onChanged: (bool value) {
                                  setState(() {
                                    _isAbsolute = value;
                                  });
                                },
                              ),
                              const Text('包名是否一致'),
                              Switch(
                                value: _isPackageNameSame,
                                onChanged: (bool value) {
                                  setState(() {
                                    _isPackageNameSame = value;
                                    if (_packageName.text != '' && value) {
                                      _controllerPackageName.text =
                                          _packageName.text;
                                      _servicePackageName.text =
                                          _packageName.text;
                                      _serviceImplPackageName.text =
                                          _packageName.text;
                                      _repositoryPackageName.text =
                                          _packageName.text;
                                      _dtoPackageName.text = _packageName.text;
                                      _formPackageName.text = _packageName.text;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          // const Text('如果使用相对路径，则entiy，controller。。。等文件夹的路径可以手动输入，如果使用绝对路径，则需要手动选择',
                          // style: TextStyle(fontSize: 10, color: Colors.red),),
                        ],
                      ),
                    ),
                    if (!_isAbsolute)
                      Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: TextField(
                              readOnly: true,
                              maxLines: 1,
                              controller: _basePath,
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: "请选择项目根目录",
                                  suffixIcon: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    child: ElevatedButton(
                                        onPressed: () async {
                                          String? selectedDirectory =
                                              await FilePicker.platform
                                                  .getDirectoryPath();
                                          _basePath.text = selectedDirectory!;
                                        },
                                        child: const Text("选择")),
                                  )),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            margin: const EdgeInsets.only(top: 10),
                            child: ElevatedButton(
                                onPressed: () {
                                  _searchLoading = true;

                                  if (_packageName.text == '' ||
                                      _basePath.text == '') {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("提示"),
                                          content: const Text("包名/项目根目录不能为空"),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("确定")),
                                          ],
                                        );
                                      },
                                    );
                                    return;
                                  }

                                  getAllDirByPath(_basePath.text);
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("提示"),
                                        content: const Text("检索完成"),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("确定")),
                                        ],
                                      );
                                    },
                                  );
                                  _searchLoading = false;
                                },
                                child: const Text("尝试自动检索路径")),
                          ),
                        ],
                      ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: _isAbsolute
                          ? TextField(
                              readOnly: true,
                              maxLines: 1,
                              controller: _entityPath,
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: "Entity绝对路径",
                                  suffixIcon: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    child: ElevatedButton(
                                        onPressed: () async {
                                          String? selectedDirectory =
                                              await FilePicker.platform
                                                  .getDirectoryPath();
                                          _entityPath.text = selectedDirectory!;
                                        },
                                        child: const Text("选择")),
                                  )),
                            )
                          : TextField(
                              maxLines: 1,
                              controller: _entityPath,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Entity相对路径",
                              ),
                            ),
                    )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      child: _isAbsolute
                          ? TextField(
                              readOnly: true,
                              maxLines: 1,
                              controller: _controllerPath,
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: "Controller绝对路径",
                                  suffixIcon: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        String? selectedDirectory =
                                            await FilePicker.platform
                                                .getDirectoryPath();

                                        setState(() {
                                          _controllerPath.text =
                                              selectedDirectory!;
                                        });
                                      },
                                      child: const Text("选择"),
                                    ),
                                  )),
                            )
                          : TextField(
                              maxLines: 1,
                              controller: _controllerPath,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Controller相对路径",
                              ),
                            ),
                    ),
                    if (!_isPackageNameSame)
                      Container(
                        margin: const EdgeInsets.only(top: 0),
                        child: TextField(
                          controller: _controllerPackageName,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Controller包名"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      child: _isAbsolute
                          ? TextField(
                              readOnly: true,
                              maxLines: 1,
                              controller: _servicePath,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: "Service绝对路径",
                                suffixIcon: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      String? selectedDirectory =
                                          await FilePicker.platform
                                              .getDirectoryPath();
                                      setState(() {
                                        _servicePath.text = selectedDirectory!;
                                      });
                                    },
                                    child: const Text("选择"),
                                  ),
                                ),
                              ),
                            )
                          : TextField(
                              maxLines: 1,
                              controller: _servicePath,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Service相对路径",
                              ),
                            ),
                    ),
                    if (!_isPackageNameSame)
                      Container(
                        margin: const EdgeInsets.only(top: 0),
                        child: TextField(
                          controller: _servicePackageName,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Service包名",
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      child: _isAbsolute
                          ? TextField(
                              readOnly: true,
                              maxLines: 1,
                              controller: _serviceImplPath,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: "ServiceImpl绝对路径",
                                suffixIcon: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      String? selectedDirectory =
                                          await FilePicker.platform
                                              .getDirectoryPath();
                                      setState(() {
                                        _serviceImplPath.text =
                                            selectedDirectory!;
                                      });
                                    },
                                    child: const Text("选择"),
                                  ),
                                ),
                              ),
                            )
                          : TextField(
                              maxLines: 1,
                              controller: _serviceImplPath,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "ServiceImpl相对路径",
                              ),
                            ),
                    ),
                    if (!_isPackageNameSame)
                      Container(
                        margin: const EdgeInsets.only(top: 0),
                        child: TextField(
                          controller: _serviceImplPackageName,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "ServiceImpl包名",
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      child: _isAbsolute
                          ? TextField(
                              readOnly: true,
                              maxLines: 1,
                              controller: _repositoryPath,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: "Repository绝对路径",
                                suffixIcon: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      String? selectedDirectory =
                                          await FilePicker.platform
                                              .getDirectoryPath();
                                      setState(() {
                                        _repositoryPath.text =
                                            selectedDirectory!;
                                      });
                                    },
                                    child: const Text("选择"),
                                  ),
                                ),
                              ),
                            )
                          : TextField(
                              maxLines: 1,
                              controller: _repositoryPath,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Repository绝对路径",
                              ),
                            ),
                    ),
                    if (!_isPackageNameSame)
                      Container(
                        margin: const EdgeInsets.only(top: 0),
                        child: TextField(
                          controller: _repositoryPackageName,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Repository包名"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      child: _isAbsolute
                          ? TextField(
                              readOnly: true,
                              maxLines: 1,
                              controller: _dtoPath,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: "Dto绝对路径",
                                suffixIcon: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      String? selectedDirectory =
                                          await FilePicker.platform
                                              .getDirectoryPath();
                                      setState(() {
                                        _dtoPath.text = selectedDirectory!;
                                      });
                                    },
                                    child: const Text("选择"),
                                  ),
                                ),
                              ),
                            )
                          : TextField(
                              maxLines: 1,
                              controller: _dtoPath,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Dto相对路径",
                              ),
                            ),
                    ),
                    if (!_isPackageNameSame)
                      Container(
                        margin: const EdgeInsets.only(top: 0),
                        child: TextField(
                          controller: _dtoPackageName,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(), labelText: "Dto包名"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      child: _isAbsolute
                          ? TextField(
                              readOnly: true,
                              maxLines: 1,
                              controller: _formPath,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: "Form绝对路径",
                                suffixIcon: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      String? selectedDirectory =
                                          await FilePicker.platform
                                              .getDirectoryPath();
                                      setState(() {
                                        _formPath.text = selectedDirectory!;
                                      });
                                    },
                                    child: const Text("选择"),
                                  ),
                                ),
                              ),
                            )
                          : TextField(
                              maxLines: 1,
                              controller: _formPath,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Form相对路径",
                              ),
                            ),
                    ),
                    if (!_isPackageNameSame)
                      Container(
                        margin: const EdgeInsets.only(top: 0),
                        child: TextField(
                          controller: _formPackageName,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Form包名"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 生成controller
  void _createControllerFile(String entityName, String entityNameLow) async {
    var readAsString =
        await rootBundle.loadString('assets/templates/controller.template');
    var template =
        Template(readAsString, name: "/${entityName}Controller.java");
    var output = template.renderString({
      'packageName': _controllerPackageName.text,
      'entityNameUp': entityName,
      'entityNameLow': entityNameLow,
    });
    File file = File((!_isAbsolute
            ? (_basePath.text + _controllerPath.text)
            : _controllerPath.text) +
        "/${entityName}Controller.java");
    var bool = await file.exists();
    if (bool) {
      return;
    }
    file.writeAsString(output);
  }

  /// 生成service
  void _createServiceFile(String entityName, String entityNameLow) async {
    var readAsString =
        await rootBundle.loadString('assets/templates/service.template');
    var template = Template(readAsString, name: "/${entityName}Service.java");
    var output = template.renderString({
      'packageName': _servicePackageName.text,
      'entityNameUp': entityName,
      'entityNameLow': entityNameLow,
    });
    File file = File((!_isAbsolute
            ? (_basePath.text + _servicePath.text)
            : _servicePath.text) +
        "/${entityName}Service.java");
    var bool = await file.exists();
    if (bool) {
      return;
    }
    file.writeAsString(output);
  }

  /// 生成serviceImpl
  void _createServiceImplFile(String entityName, String entityNameLow) async {
    var readAsString =
        await rootBundle.loadString('assets/templates/serviceImpl.template');
    var template =
        Template(readAsString, name: "/${entityName}ServiceImpl.java");
    var output = template.renderString({
      'packageName': _serviceImplPackageName.text,
      'entityNameUp': entityName,
      'entityNameLow': entityNameLow,
    });
    File file = File((!_isAbsolute
            ? (_basePath.text + _serviceImplPath.text)
            : _serviceImplPath.text) +
        "/${entityName}ServiceImpl.java");
    var bool = await file.exists();
    if (bool) {
      return;
    }
    file.writeAsString(output);
  }

  /// 生成repository
  void _createRepositoryFile(String entityName, String entityNameLow) async {
    var readAsString =
        await rootBundle.loadString('assets/templates/repository.template');
    var template =
        Template(readAsString, name: "/${entityName}Repository.java");
    var output = template.renderString({
      'packageName': _repositoryPackageName.text,
      'entityNameUp': entityName,
      'entityNameLow': entityNameLow,
    });
    File file = File((!_isAbsolute
            ? (_basePath.text + _repositoryPath.text)
            : _repositoryPath.text) +
        "/${entityName}Repository.java");
    var bool = await file.exists();
    if (bool) {
      return;
    }
    file.writeAsString(output);
  }

  /// 生成dto
  void _createDtoFile(String entityName, String entityNameLow) async {
    var readAsString =
        await rootBundle.loadString('assets/templates/dto.template');
    var template = Template(readAsString, name: "/${entityName}Dto.java");
    var output = template.renderString({
      'packageName': _dtoPackageName.text,
      'entityNameUp': entityName,
      'entityNameLow': entityNameLow,
    });
    File file = File(
        (!_isAbsolute ? (_basePath.text + _dtoPath.text) : _dtoPath.text) +
            "/${entityName}Dto.java");
    var bool = await file.exists();
    if (bool) {
      return;
    }
    file.writeAsString(output);
  }

  /// 生成form
  void _createFormFile(String entityName, String entityNameLow) async {
    var readAsString =
        await rootBundle.loadString('assets/templates/form.template');
    var template = Template(readAsString, name: "/${entityName}Form.java");
    var output = template.renderString({
      'packageName': _formPackageName.text,
      'entityNameUp': entityName,
      'entityNameLow': entityNameLow,
    });
    File file = File(
        (!_isAbsolute ? (_basePath.text + _formPath.text) : _formPath.text) +
            "/${entityName}Form.java");
    var bool = await file.exists();
    if (bool) {
      return;
    }
    file.writeAsString(output);
  }

  /// 递归获取所有文件夹
  void getAllDirByPath(String path) {
    var packageNamePath = _packageName.text.replaceAll('.', '/');
    var dir = Directory(path);
    var listSync = dir.listSync();
    for (var item in listSync) {
      Directory dir = Directory(item.path);
      var existsSync = dir.existsSync();
      if (existsSync) {
        if (item.path.endsWith('/src/main/java/$packageNamePath/entity')) {
          _entityPath.text = item.path.replaceAll(_basePath.text, '');
        }
        if (item.path.endsWith('/src/main/java/$packageNamePath/controller')) {
          _controllerPath.text = item.path.replaceAll(_basePath.text, '');
        }
        if (item.path.endsWith('/src/main/java/$packageNamePath/service')) {
          _servicePath.text = item.path.replaceAll(_basePath.text, '');
        }
        if (item.path
            .endsWith('/src/main/java/$packageNamePath/service/impl')) {
          _serviceImplPath.text = item.path.replaceAll(_basePath.text, '');
        }
        if (item.path.endsWith('/src/main/java/$packageNamePath/repository')) {
          _repositoryPath.text = item.path.replaceAll(_basePath.text, '');
        }
        if (item.path.endsWith('/src/main/java/$packageNamePath/dto')) {
          _dtoPath.text = item.path.replaceAll(_basePath.text, '');
        }
        if (item.path.endsWith('/src/main/java/$packageNamePath/form')) {
          _formPath.text = item.path.replaceAll(_basePath.text, '');
        }

        if (Directory(item.path).listSync().isNotEmpty) {
          getAllDirByPath(item.path);
        }
      }
    }
  }
}
