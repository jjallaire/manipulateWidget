% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/manipulateWidget.R
\name{manipulateWidget}
\alias{manipulateWidget}
\title{Add Controls to Interactive Plots}
\usage{
manipulateWidget(.expr, ..., .main = NULL, .updateBtn = FALSE,
  .controlPos = c("left", "top", "right", "bottom", "tab"), .tabColumns = 2,
  .viewer = c("pane", "window", "browser"), .display = NULL)
}
\arguments{
\item{.expr}{expression to evaluate that returns an interactive plot of class
\code{htmlwidget}. This expression is re-evaluated each time a control is
modified.}

\item{...}{One or more named control arguments created with functions
\code{\link{mwSlider}}, \code{\link{mwText}}, etc. The name of each control
is the name of the variable the controls modifies in the expression. One
can also create a group of inputs by passing a list of such control
arguments. for instance
\code{mygroup = list(txt = mwText(""), nb = mwNumeric(0))} creates a group
of inputs named mygroup with two inputs named "txt" and "nb".}

\item{.main}{Title of the shiny gadget}

\item{.updateBtn}{Should an update button be added to the controls ? If \code{TRUE}, then
the graphic is updated only when the user clicks on the update button.}

\item{.controlPos}{Where controls should be placed ? By default, they are placed in the left,
next to the graphic. If \code{controlPos = "tab"}, two tabs are created:
one containing controls and the other containing the graphic.}

\item{.tabColumns}{If controls are placed in a distinct tab, how many columns should be
used ? This parameter is used only if \code{controlPos = "tab"}}

\item{.viewer}{Controls where the gadget should be displayed. \code{"pane"} corresponds to
the Rstudio viewer, \code{"window"} to a dialog window, and \code{"browser"}
to an external web browser.}

\item{.display}{A named list of conditions that evaluate to TRUE OR FALSE indicating when
inputs should be displayed. These conditions are reevaluated each time a
control it modified. By default, each control is displayed, but if the name
of a control appears in this list, then the associated condition is
evaluated. If the result is TRUE then the control is visible, else it is
hidden.}
}
\value{
The result of the expression evaluated with the last values of the control.
It should be an object of class \code{htmlWidget}.
}
\description{
This function permits to add controls to an interactive plot created with
packages like \code{dygraphs}, \code{highcharter} or \code{plotly} in order
to change the input data or the parameters of the plot.

Technically, the function starts a shiny gadget. The R session is bloqued
until the user clicks on "cancel" or "done". If he clicks on "done", then the
the function returns the last displayed plot so the user can modify it and/or
save it.
}
\section{Advanced Usage}{

The "normal" use of the function is to provide an expression that always
return an \code{htmlwidget}. In such case, every time the user changes the
value of an input, the current widget is destroyed and a new one is created
and rendered.

Some packages provide functions to update a widget that has already been
rendered. This is the case for instance for package \code{leaflet} with the
function \code{\link[leaflet]{leafletProxy}}. To use such functions,
\code{manipulateWidget} evaluates the parameter \code{.expr} with two extra
variables:

\itemize{
  \item{\code{.initial}:}{
    \code{TRUE} if the expression is evaluated for the first time and then
    the widget has not been rendered yet, \code{FALSE} if the widget has
    already been rendered.
  }
  \item{\code{.session}:}{
    A shiny session object.
  }
}

Moreover the ID of the rendered widget will always be "output".

You can take a look at the last example to see how to use these two
variables to update a leaflet widget.
}
\examples{
if (require(dygraphs)) {

  mydata <- data.frame(year = 2000+1:100, value = rnorm(100))
  manipulateWidget(dygraph(mydata[range[1]:range[2] - 2000, ], main = title),
                   range = mwSlider(2001, 2100, c(2001, 2100)),
                   title = mwText("Fictive time series"))

}

# Grouping inputs
if (require(dygraphs)) {

  mydata <- data.frame(year = 2000+1:100, value = rnorm(100))
  manipulateWidget(dygraph(mydata[range[1]:range[2] - 2000, ],
                           main = title, xlab = xlab, ylab = ylab),
                   range = mwSlider(2001, 2100, c(2001, 2100)),
                   "Graphical parameters" = list(
                      title = mwText("Fictive time series"),
                      xlab = mwText("X axis label"),
                      ylab = mwText("Y axis label")
                   )
                  )

}

# Example of conditional input controls
#
# In this example, we plot a x series against a y series. User can choose to
# use points or lines. If he chooses lines, then an additional input is displayed
# to let him control the width of the lines.
if (require("plotly")) {

  dt <- data.frame (
    x = sort(runif(100)),
    y = rnorm(100)
  )

  myPlot <- function(type, lwd) {
    if (type == "points") {
      plot_ly(dt, x= ~x, y = ~y, type = "scatter", mode = "markers")
    } else {
      plot_ly(dt, x= ~x, y = ~y, type = "scatter", mode = "lines", line = list(width = lwd))
    }
  }

  manipulateWidget(
    myPlot(type, lwd),
    type = mwSelect(c("points", "lines"), "points"),
    lwd = mwSlider(1, 10, 1),
    .display = list(lwd = type == "lines")
  )

}

# Advanced Usage
#
# .expr is evaluated with two extra variables .initial and .session that can
# be used to update an already rendered widget instead of replacing it each
# time an input value is modified.
#
# Here we generate a UI that permits to change color and size of arbitrary
# points on a map generated with leaflet.

if (require(leaflet)) {
  lon <- rnorm(10, sd = 20)
  lat <- rnorm(10, sd = 20)

  myMapFun <- function(radius, color, initial, session) {
    if (initial) {
      # Widget has not been rendered
      map <- leaflet() \%>\% addTiles()
    } else {
      # widget has already been rendered
      map <- leafletProxy("output", session) \%>\% clearMarkers()
    }

    map \%>\% addCircleMarkers(lon, lat, radius = radius, color = color)
  }

  manipulateWidget(myMapFun(radius, color, .initial, .session),
                   radius = mwSlider(5, 30, 10),
                   color = mwSelect(c("red", "blue", "green")))

}

}

