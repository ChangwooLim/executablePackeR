# executablePackeR

## Dependency

- R
- Node.js
- Electron Forge (using npm)

Currently, Windows and macOS(with Apple Silicon processors) are tested and supported.

This package may work with Mac with Intel processors, but not tested. Test

You should use appropriate OS for your purpose. For example, if you want to make a Windows Executable File(EXE), you should use Windows. Same to macOS.

## Installation

Run

```
remotes::install_github("ChangwooLim/executablePackeR")
or
~~install.packages("executablePackeR")~~ Will be available soon.
```

## Before start

Run `npm i -g @electron-forge/cli` in your terminal to install electron in your system.

(macOS) If your account don't have proper permission, run `sudo npm i -g @electron-forge/cli`

Packages used in your application not available at CRAN should be installed at your computer.

## Options

See option_description.md for more information.

## Troubleshooting

- Executable built successfully, but infinite loading after running.

-> Run `executablePackeR::pack(option=list(is_dev=TRUE))`
-> with is_dev option, processed file will not be deleted, and tempdir path will be printed at last.
-> Open terminal, run `cd <tempdir path printed at your cosole>` 
-> Run `electron-forge start` and see what is the problem.

For another issues not described above, use Issue tab for reporting issues and requesting features.

When you stuck at after "Installing R Complete" and see warning(or error) "Could not parse R code in",
Run 

```
Sys.setlocale(category = 'LC_ALL' , locale = '')
```

or

```
Sys.setlocale(category = 'LC_ALL' , locale = 'en_US.UTF-8')
```

at your R Console.

It might be a encoding problem, and may occurs at Windows Server Environment.

## Credit

This package is developed under support of [Zarathu Corporation](https://www.zarathu.com)

Thanks to [Jinhwan Kim](https://github.com/jhk0530) and Travis Hinkelman, Dirk Shumacher for making shiny-electron-template [#macOS](https://github.com/zarathucorp/shiny-electron-template-m1) [#Windows](https://github.com/zarathucorp/shiny-electron-template-windows)

(Windows) This package downloads [Innoextract](https://constexpr.org/innoextract/) for unpacking R setup file. See [GitHub](https://github.com/dscharrer/innoextract) for source code.

## Contact

Contact [limcw@zarathu.com](mailto:limcw@zarathu.com) for non-public inquiry.

