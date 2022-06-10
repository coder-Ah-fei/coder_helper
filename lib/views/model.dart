

/// 生成文件需要的参数
class ParamsModel {

  final String packageName;
  final String basePath;
  final String entityPath;
  final String controllerPath;
  final String controllerPackageName;
  final String servicePath;
  final String servicePackageName;
  final String serviceImplPath;
  final String serviceImplPackageName;
  final String repositoryPath;
  final String repositoryPackageName;
  final String dtoPath;
  final String dtoPackageName;
  final String formPath;
  final String formPackageName;

  ParamsModel(
      this.packageName,
      this.basePath,
      this.entityPath,
      this.controllerPath,
      this.controllerPackageName,
      this.servicePath,
      this.servicePackageName,
      this.serviceImplPath,
      this.serviceImplPackageName,
      this.repositoryPath,
      this.repositoryPackageName,
      this.dtoPath,
      this.dtoPackageName,
      this.formPath,
      this.formPackageName);
}