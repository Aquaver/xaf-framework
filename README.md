<p align="center">
  <img alt="XAF Logo" src="https://raw.githubusercontent.com/Aquaver/xaf-framework/master/assets/logo.png"><br><br>
  <img alt="Latest development release version" src="https://img.shields.io/badge/latest_development_release-1.0.0-orange.svg">
  <img alt="Latest stable release version" src="https://img.shields.io/badge/latest_stable_release-1.0.0-brightgreen.svg">
  <img alt="Requied OS" src="https://img.shields.io/badge/required_OS-OpenOS_1.7-blue.svg">
</p>

Extensible Application Framework is a development package for Minecraft modification - OpenComputers. This open-source project makes programming applications with GUI more and more easy, but not only. It consists of several modules: core, graphic, network and utilities. Each of these modules also contains many libraries so possibilities of this framework are unlimited. Initially it was designed to provide many useful GUI controls but currently it has also quite a few classes which help to build a computer network for example, or a redstone controller terminal.

## XAF module list with description

* **Core** - The most important module which currently has only one class. This class - `Core:XAFCore` - is divided into parts called instances that have essential methods for processing binary data or exporting table to file format.
* **Graphic** - So far the most complex module which delivers several classes for building a graphical user interface. It consists of simple controls like buttons or two-state switches, or input components like text fields or password fields.
* **Network** - Generally this module has two classes that are interfaces for creating custom network protocols - one for client sided and the other for server. Despite this it possesses also defined and ready to use basic protocols - DNS, DTP and FTP, which may be extended and developed by the user.
* **Utility** - Module category that contains useful libraries which could not be classified to the other groups. For the time being there are among others classes that provide basic HTTP connections or simplified redstone manipulation.
