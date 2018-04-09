<p align="center">
  <img alt="XAF Logo" src="https://raw.githubusercontent.com/Aquaver/xaf-framework/master/assets/logo.png"><br><br>
  <img alt="Latest development release version" src="https://img.shields.io/badge/latest_development_release-1.0.0-orange.svg">
  <img alt="Latest stable release version" src="https://img.shields.io/badge/latest_stable_release-1.0.0-brightgreen.svg">
  <img alt="Required OS" src="https://img.shields.io/badge/required_OS-OpenOS_1.7-blue.svg">
</p>

Extensible Application Framework is a development package for Minecraft modification - OpenComputers. This open-source project makes programming applications with GUI more and more easy, but not only. It consists of several modules: core, graphic, network and utilities. Each of these modules also contains many libraries so possibilities of this framework are unlimited. Initially it was designed to provide many useful GUI controls but currently it has also quite a few classes which help to build a computer network for example, or a redstone controller terminal.

## XAF module list with description

* **Core** - The most important module which currently has only one class. This class - `Core:XAFCore` - is divided into parts called instances that have essential methods for processing binary data or exporting table to file format.
* **Graphic** - So far the most complex module which delivers several classes for building a graphical user interface. It consists of simple controls like buttons or two-state switches, or input components like text fields or password fields.
* **Network** - Generally this module has two classes that are interfaces for creating custom network protocols - one for client sided and the other for server. Despite this it possesses also defined and ready to use basic protocols - DNS, DTP and FTP, which may be extended and developed by the user.
* **Utility** - Module category that contains useful libraries which could not be classified to the other groups. For the time being there are among others classes that provide basic HTTP connections or simplified redstone manipulation.

The XAF project is directed in particular to all users who would like to create their own more or less complex applications, especially with graphical user interface, without advanced programming or development knowledge. Only basic skills in Lua language and access to XAF documentation are needed. Provided comprehensive but simple specification with some usage examples let the user create powerful programs. Furthermore, fully implemented object oriented programming paradigm within most of its advantages like class encapsulation and inheritance allows separating all functionalities logically. At the same time, source code of XAF based applications are clear, compact and at most lightweight. Finally, as the project name says, this framework is open to user's additions and extensions. This functionality is possible with implemented OOP powerful mechanism - inheritance, which allows creating new derivative classes from the existing ones without user interference in them. Everyone who create some custom classes and mechanisms can add, remove and share them with others very easily. The management of XAF package is also very simple. With built-in API controller and implemented commands the user is able to initialize, uninstall or even update to newer (or change to older too) XAF version.

## XAF advantages and features

* **Object oriented** - Implementation most of OOP paradigm mechanisms like encapsulation and inheritance make using XAF in creating user programs significantly. Treating all entities as 'objects' simplifies managing them, arranges source code and makes it more brief and easy to understand.
* **Modularity** - All logical features with their classes (source code files) are kept separately and treated hierarchically as standalone modules. Because of this, it is very easy to extend XAF with custom, user created mechanisms (modules). What is more, everyone can share these functionalities in simple way.
* **Flexibility** - As the standard definition of framework mentions, it should allow the user to precisely define behavior of used components. This software does not deviate from that rules. Every element both graphic, network and the others might be configured in aspect of 'how it works' and 'how it behaves'. For example, the user is able to declare which GPU (in case of more than one) should render specified GUI element, or which network card (also when have more than one) will be responsible for server working. This feature would let use XAF on multi-component (for example multi-screen) systems.
* **Easy control** - The entire XAF package does not consist of API with its classes only. Above all, it possesses powerful and extensible controlling program with modular command system. This controller allows the user to very easy and simple management with XAF, for example initializing, checking for updates, switching (updating) between versions and uninstalling. Most of these actions may be performed automatically within one command.

## Example GUI based on XAF controls

<p align="center">
  <img alt="Example GUI" src="https://raw.githubusercontent.com/Aquaver/xaf-framework/master/assets/example.png">
</p>

This picture shows an example graphical user interface made by means of XAF built-in graphic module. As you can see, every component can be precisely set and configured with its corresponding class functions. Most of these GUI elements are very simple to use and require couple lines of code to work properly, but there are also few more complex components like text areas, password fields or lists, which may work correctly after right preparation. However, all GUI controls that work on user activity (buttons, input fields, sliders etc...) share one function with the same name `register()` whose syntax is the same to all variants, and accepts only one parameter - event table from `event.pull()` function from OC Event API.

## Installation

### Minimum system requirements

* **Internet** - Access to internet through Internet Card.
* **Computer** - Both screen and GPU components at tier 3 (teal color).
* **Memory** - About 100 kB of free memory for minified version or about 300 kB for full source version.
* **Dependencies** - Original OpenOS (required system version is shown next to release versions).

### Automated installation

* **For latest version** - `wget https://raw.githubusercontent.com/Aquaver/xaf-framework/master/installer.lua xaf-installer.lua && xaf-installer.lua && rm xaf-installer.lua`
* **For specified release** - `wget https://raw.githubusercontent.com/Aquaver/xaf-framework/VERSION_NUMBER/installer.lua xaf-installer.lua && xaf-installer.lua && rm xaf-installer.lua`

### Manual installation

* Proceed to Releases page on XAF GitHub page.
* Choose specified version and download the file `Installer.lua`.
* Copy the downloaded file to OpenComputers filesystem directory.
* Run the installer directly from command line.
