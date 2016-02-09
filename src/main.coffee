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

if process.argv.length isnt 4
  console.log 'Usage: ChessGame server:port key'
  process.exit 1

unless(s = /(.+?):([\d]+)/.exec process.argv[2])
  console.log 'Usage: ChessGame server:port key'
  process.exit 1

server = s[0]
port = parseInt(s[1])
key = process.argv[3]

Game = require './game'
Input = require './input'
Network = require './network'
Chain = require './chain'

if server is 'localhost'
  socket = Network.createServer port, key
  inputs = [new Input(), new Input()]
else
  socket = Network.createClient server, port, key
  inputs = [new Input(), new Input()]

_.init() for _ in inputs
game = new Game
game.setChain new Chain(key: key)
game.setInputs inputs
game.start (msg) ->
  console.log "Game finished: #{msg}"
