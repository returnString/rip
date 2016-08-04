# rip
Simple package management for R.

# Commands
- `rip init` initialises an empty manifest
- `rip install <package>` installs one or more packages and records them in your manifest
- `rip restore` installs all packages referenced in your manifest
- `rip list` displays a list of currently installed packages with their versions

# Example
Firstly, someone creates a project, installs _Shiny_ and _ggplot2_, then uploads the project to GitHub.

```bash
mkdir myproject
cd myproject

rip init
rip install ggplot2 shiny

git init
git add .
git commit -m "My first R dependencies!"
git remote add origin git@github.com:user/myproject.git
git push origin HEAD
```

A second user then clones the project and restores.

```bash
git clone git@github.com:user/myproject.git
cd myproject

rip restore
```

Both users now have all the dependencies required to run the app, without using `install.packages` manually.