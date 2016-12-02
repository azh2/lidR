# ===============================================================================
#
# PROGRAMMERS:
#
# jean-romain.roussel.1@ulaval.ca  -  https://github.com/Jean-Romain/lidR
#
# COPYRIGHT:
#
# Copyright 2016 Jean-Romain Roussel
#
# This file is part of lidR R package.
#
# lidR is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>
#
# ===============================================================================



#' Canopy surface model
#'
#' Creates a canopy surface model using a LiDAR cloud of points. For each pixel the
#' function returns highest point found. This basic method could be improved by replacing
#' each LiDAR return with a small disk
#'
#' The algorithm used is the local maximum algorithm. It assigns the
#' elevation of the highest return within each grid cell to the grid cell center.
#' @aliases  grid_canopy
#' @param .las An object of class \code{LAS}
#' @param res numeric. The size of a grid cell in LiDAR data coordinates units. Default is
#' 2 meters i.e. 4 square meters.
#' @param subcircle numeric radius of the circles. To fill empty pixels the algorithm can
#' replaces each return by a circle composed by 8 points before to compute the maximum elevation
#' in each pixel.
#' @return It returns a \code{data.table} with the class \code{grid_metrics} which enables easier plotting.
#' @examples
#' LASfile <- system.file("extdata", "Megaplot.laz", package="lidR")
#' lidar = readLAS(LASfile)
#'
#' # Local maximum algorithm with a resolution of 2 meters
#' lidar %>% grid_canopy(2) %>% plot
#' @family grid_alias
#' @seealso
#' \link[lidR:grid_metrics]{grid_metrics}
#' @export grid_canopy
grid_canopy = function(.las, res = 2, subcircle = 0)
{
  Z <- NULL

  ex = extent(.las)

  if(subcircle > 0)
  {
    dt = .las@data[, .(X,Y,Z)]

    alpha = seq(0, 2*pi, length.out = 9)[-9]
    px = subcircle*cos(alpha)
    py = subcircle*sin(alpha)

    dt = dt[, subcircled(X,Y,Z, px,py), by = rownames(dt)][, rownames := NULL]
    dt = dt[between(X, ex@xmin, ex@xmax) & between(Y, ex@ymin, ex@ymax)]
    .las = LAS(dt)

    rm(dt)
  }

  ret = grid_metrics(.las, res, list(Z = max(Z)))

  rm(.las)
  gc()

  return(ret)
}

subcircled = function(x, y, z, px, py)
{
  i = which.max(z)
  x = x[i]
  y = y[i]
  z = z[i]

  x = x + px
  y = y + py
  z = rep(z, length(px))

  list(X = x, Y = y, Z = z)
}
