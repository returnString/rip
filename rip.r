#!/usr/bin/env RScript

repoConfig <- getOption("repos")
repoConfig["CRAN"] = "http://cran.r-project.org/"
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
	install.packages(packages, verbose = F, quiet = T)
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
	package <- args[2]
	
	if (is.na(package))
	{
		stop("Please specify a package")
	}

	if (!(package %in% available.packages()[,"Package"]))
	{
		stop("Package is not available in the repository: ", package)
	}

	packages <- loadPackages()
	if (package %in% packages)
	{
		stop("Package is already installed: ", package)
	}

	info("Installing package: ", package)
	quietInstall(package)
	savePackages(c(packages, package))
}

init <- function()
{
	assertPwd(F)
	file.create(manifestName)
}

list <- function()
{
	assertPwd(T)
	packages <- loadPackages()

	for (package in packages)
	{
		version <- packageVersion(package)
		info(package, ": ", version)
	}
}

main <- function()
{
	commandName <- args[1]
	command <- switch(commandName,
		init = init,
		install = install,
		restore = restore,
		list = list,
		stop("Invalid command: ", commandName))

	command()
}

main()