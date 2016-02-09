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
  class Game
    constructor: ->
    setChain: (@chain) ->
    setInputs: (@inputs) ->
      if @inputs.length isnt 2 then throw new Error('Game requires exactly 2 players')

    start: (@finish) ->
      @turn = false
      @next()

    stop: (msg) ->
      @finish?(msg)

    evaluate: (cmd) ->
      console.log "Turn #{@turn - 0}: #{cmd}"

    next: ->
      @inputs[@turn - 0].getCommand (cmd, err) =>
        return @stop(err) unless cmd? and cmd isnt 'exit'
        @evaluate cmd
        @turn = not @turn
        @next()
