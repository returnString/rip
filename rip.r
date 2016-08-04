#!/usr/bin/env RScript

repoConfig <- getOption("repos")
repoConfig["CRAN"] = "http://cran.r-project.org/"
options(repos = repoConfig)

manifestName <- '.rip'
args <- commandArgs(trailingOnly = T)

assertPwd <- function(isRipProject)
{
	if (isRipProject != file.exists(manifestName))
	{
		stop(paste("Current directory", if (isRipProject) "is not" else "is already" , "a rip project"))
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

restore <- function()
{
	assertPwd(T)
	packages <- loadPackages()

	if (!length(packages))
	{
		stop("No packages in manifest to restore")
	}

	install.packages(packages)
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
		stop("Package is not available in the repository")
	}

	packages <- loadPackages()
	if (package %in% packages)
	{
		stop("Package is already installed")
	}

	install.packages(package)
	savePackages(c(packages, package))
}

init <- function()
{
	assertPwd(F)
	file.create(manifestName)
}

invalidCommand <- function()
{
	stop("Invalid command")
}

main <- function()
{
	command <- switch(args[1],
		init = init,
		install = install,
		restore = restore,
		invalidCommand)

	command()
}

main()