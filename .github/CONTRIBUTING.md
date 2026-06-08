## Contributing to this package

There are lots of ways you can contribute to this package. All contributions are most welcome and only some of these require technical knowledge. If you have something to contribute but aren't sure how, please don't hesitate to log an issue. 

The below guidelines outline how to propose a change to this package. We abide by the contributing guidelines developed by the tidyverse. For more detailed info about contributing to this package, please see the [tidyverse development contributing guide](https://www.tidyverse.org/contribute/). 

### Fixing typos 

You can fix typos, spelling mistakes, or grammatical errors in the documentation directly using the GitHub web interface, as long as the changes are made in the source file. This generally means you'll need to edit [roxygen2 comments](https://roxygen2.r-lib.org/articles/roxygen2.html) in an `.R`, not a `.Rd` file. You can find the `.R` file that generates the `.Rd` by reading the comment in the first line.

### Bigger changes

If you want to make a bigger change, it's a good idea to first file an issue and make sure someone from the team agrees that it’s needed. If you’ve found a bug, please file an issue that illustrates the bug with a minimal [reprex](https://www.tidyverse.org/help/#reprex). This will also help you write a unit test, if needed.

### Pull request process

- Fork the package and clone onto your computer. If you haven't done this before, we recommend using `usethis::create_from_github("Bisaloo/grumpy", fork = TRUE)`.
- Install all development dependencies with `devtools::install_dev_deps()`, and then make sure the package passes R CMD check by running `devtools::check()`. If R CMD check doesn't pass cleanly, it's a good idea to ask for help before continuing.
- Create a Git branch for your pull request (PR). We recommend using `usethis::pr_init("brief-description-of-change")`.
- Make your changes, commit to git, and then create a PR by running `usethis::pr_push()`, and following the prompts in your browser. The title of your PR should briefly describe the change. The body of your PR should contain Fixes #issue-number.
- For user-facing changes, add a bullet to the top of `NEWS.md` (i.e. just below the first header). Follow the style described in https://style.tidyverse.org/news.html.

### What happens after submitting a pull request?

PRs are reviewed by the team before they are merged. The review process begins after continuous integration automated checks, which can take some time. We do not expect contributors to familiarise themselves with all the automated checks in our GitHub actions, and are happy to support on this once a PR is made. 

If possible, we recommend you run the automated checks on your local computer first for easier troubleshooting and a reduced cloud computing resource usage. Here is a summary of the main checks that are automatically performed and how they can be confirmed:

- Run `lintr::lint_package()` to check for programmatic and stylistic errors in code.
- Run `devtools::document()` to regenerate the .Rd files if changes were made to documentation.
- Run `devtools::check()` to make sure the package passes R CMD check (see previous section). You may prefer to run individual checks such as `spelling::spell_check_test()` to check spelling and `testthat::test_package()` to check that package tests are still passing before running this more comprehensive check.

### Code style

- New code should follow the tidyverse [style guide](https://style.tidyverse.org/news.html). You can use the [air](https://posit-dev.github.io/air/) utility to apply these styles, but please don't restyle code that has nothing to do with your PR.
- We use [roxygen2](https://cran.r-project.org/web/packages/roxygen2/index.html) for basic documentation, [rmarkdown](https://rmarkdown.rstudio.com/docs/) for vignettes and [pkgdown](https://pkgdown.r-lib.org/) for websites.
- We use [testthat](https://cran.r-project.org/web/packages/testthat/index.html) for unit tests. Contributions with test cases included are easier to accept.

### Use cases

We are always interested in hearing about how packages are being applied. This helps inform future development priorities by identifying which features are the most used, and which parts of the project lack clarity or need improvement. If you have a use case which you would like to share with the wider community, please do let us know. We're grateful for any way that you can spread the word. Whether that's citing packages in your papers or telling your friends about a feature you found useful.

### Code of Conduct

This package has adopted [rOpenSci Code of Conduct](https://ropensci.org/code-of-conduct/). Please ensure you read and understand it before contributing.
