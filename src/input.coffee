# Chess with local multi-player
# Copyright (C) 2016  Fabian Stiewitz, Simon Triem
#
# This program is free software: you can redistribute it and/or modify
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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module.exports =
  class Input
    constructor: ->

    init: ->
      process.stdin.pause()

    getCommand: (cb) ->
      process.stdin.on 'data', (data) ->
        if cb?
          process.stdin.pause()
          cb(data.toString().replace /\s/g, '')
          cb = null
      process.stdin.resume()
