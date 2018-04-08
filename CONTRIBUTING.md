# XAF Project Contributing Guidelines

Hello! You probably came to this page because you would like to contribute to XAF project and help me to make it better and better with improving it. I am glad seeing you are interested in that software and development of it. Here, you will find some instructions how to prepare your copy of this project and start contributing. If you really would like to work with XAF and help with developing, please read these rules carefully, because meeting the requirements will affect on whether your contribution will be accepted and merged or rejected.

## General project conventions

* **One per file** - Every commit should concern changes in exactly one file, because it is easier to find which change solves specific trouble. It is important, even if you are fixing typo in one sentence in documentation.
* **Use the past** - Commit messages should be in past tense (added, removed) because they say what type of changes the specific commit has done. I think it is much more easy to understand by somebody who are not technically advanced.
* **Vocabulary** - It is strongly recommended starting the commit message with one of the following words: `Added`, `Changed`, `Fixed`, `Removed` unless you have done something different, but please, keep in past tense.
* **Proper naming** - If the change deals with one of module classes, include its name in commit message (like `Core:XAFCore` or `Network:Server` for example). It also concerns your own classes, just keep the pattern `ModuleName:ClassName`.
* **Be structured** - If you are planning to create a brand-new class or a module, please read the XAF class structure documentation and base your class on available structure code.

### Project standard branch layout

```
xaf-framework
   └─ master
       ├─ stable
       │   ├─ hotfix-name
       │   └─ release-name
       └─ development
           ├─ feature-name
           ├─ fix-name
           ├─ pr-username
           │   └─ ...
           ├─ release-name
           └─ ...

[>] Master must be merged only from release-name branches either from 'stable' or 'development' on releases.
[>] All changes that concern specific version must be merged to 'release-name' before releasing.
[>] Branch named 'pr-username' is used for contributing with PR workflow.
[>] Contributors should merge all sub-branches (...) to 'pr-username' before PR.
[>] Parent branches: 'master', 'stable' and 'development' must not be removed.
```

Remember that if you feel lost with some of these conventions or if you think you did something incorrectly, please have a look among others on main commits list or on some code. However, if you still feel insecure, please do not be afraid to ask somebody from leader team - we will help you. Better ask twice than lose yourself once.

## Simple contribution workflow

1. **Local copy** - Fork from original repository or if you have your local clone already downloaded, ensure you keep it up to date, when you decide to contribute.
2. **Working branch** - Before you start working with your copy, create a new branch and name if using the following pattern `pr-username` where `pr` means pull request (all letters lowercase).
3. **Just work** - Work on your local copy (remember to commit changes to your branch) while keeping above conventions. Do not interfere in other branches than yours.
4. **The pull request** - Propose your pull request heading it to upstream branch called `development` from your branch `pr-username`, title it and write a brief description (with commit message conventions).
5. **Bug prevention** - Remember to allow the maintainers editing your created pull request, because this let the team to find and fix potential troubles.
6. **Code review** - After submitting your changes, please be patient and wait for code reviews and feedback from leader team. Good luck and happy contributing!
7. **Be in touch** - Do not forget to star the original project repository and watch it to get notified about all update news and announcements. Thank you!

## Standard version releasing procedure

These rules concern only development team directly, because they define the steps that should be done before releasing new version. You (as a project contributor) do not have to read these notes and take care of them, because they have no influence on contribution pull request review. **Important!** These steps presented below must be performed only after normal working with code and documentation, they finalize project version directly before official release.

1. Update version signature in XAF controller 'init' command script (both source and minified code).
2. Change the version number in XAF installation program.
3. Update version metadata in `package.info` file, version and release stage (either from `true` or `false` flag).
4. Note following release version number in main project description file (README.md).
5. Create the release for new version with installation program attached.
