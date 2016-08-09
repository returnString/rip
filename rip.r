sourceResult <- tryCatch({ source("~/.ripconfig") },
	error = function(e){}, warning = function(e){})

if (!exists("RIPCONFIG_CRAN_PATH"))
{
	RIPCONFIG_CRAN_PATH = "http://cran.r-project.org/"
}

if (!exists("RIPCONFIG_LIB_PATH"))
{
	RIPCONFIG_LIB_PATH = .libPaths()[1]
}

repoConfig <- getOption("repos")
repoConfig["CRAN"] = RIPCONFIG_CRAN_PATH
options(repos = repoConfig)

manifestName <- '.rip'
args <- commandArgs(trailingOnly = T)

info <- function(...)
{
	cat(paste0(...), "\n")
}

assertPwd <- function(isRipProject)
{
	if (isRipProject != file.exists(manifestName))
	{
		stop("Current directory ", if (isRipProject) "is not" else "is already" , " a rip project")
	}
}

loadPackages <- function()
{
	fh <- file(manifestName, open = "r")
	packages <- c()
	while (length(line <- readLines(fh, n = 1)) > 0)
	{
		packages <- c(packages, line);
	}
	close(fh)
	return(packages)
}

savePackages <- function(packages)
{
	fh <- file(manifestName, open = "w")
	writeLines(sort(packages), fh)
	close(fh)
}

quietInstall <- function(packages)
{
	install.packages(packages, verbose = F, quiet = T, lib = RIPCONFIG_LIB_PATH)
}

restore <- function()
{
	assertPwd(T)
	packages <- loadPackages()
	packageCount <- length(packages)

	if (!packageCount)
	{
		stop("No packages in manifest to restore")
	}

	info("Restoring ", packageCount, " package(s)")
	quietInstall(packages)
}

install <- function()
{
	assertPwd(T)
	packagesToInstall <- args[0:-1]

	if (!length(packagesToInstall))
	{
		stop("Please specify at least one package")
	}

	packages <- loadPackages()

	for (package in packagesToInstall)
	{
		if (!(package %in% available.packages()[,"Package"]))
		{
			stop("Package is not available in the repository: ", package)
		}
	}

	quietInstall(packagesToInstall)
	savePackages(union(packages, packagesToInstall))
}

init <- function()
{
	assertPwd(F)
	file.create(manifestName)
}

listVersions <- function()
{
	assertPwd(T)
	packages <- loadPackages()

	for (package in packages)
	{
		version <- packageVersion(package)
		info(package, ": ", version)
	}
}

help <- function(commandName = NA)
{
	if (!is.na(commandName))
	{
		info("Invalid command: ", commandName, "\n")
	}

	commands <- list(
		init = "initialises an empty manifest",
		install = "installs one or more packages and records them in your manifest",
		restore = "installs all packages referenced in your manifest",
		list = "displays a list of currently installed packages with their versions")

	output = paste0("rip ", names(commands), "\n  ", commands, "\n")

	info("Usage:\n")
	for (command in output)
	{
		info(command)
	}
}

main <- function()
{
	commandName <- args[1]
	command <- switch(commandName,
		init = init,
		install = install,
		restore = restore,
		list = listVersions,
		"-h" = , "--help" = , help = help,
		function() { help(commandName) })

	command()
}

dummy <- main()