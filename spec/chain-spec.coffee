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

Chain = require '../chain'

describe 'Chain', ->
  chain = null

  beforeEach ->
    chain = new Chain(key: '1234')

  describe 'on constructor', ->
    it 'initializes the list', ->
      expect(chain.null_move.h).toBe '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4'

  describe 'on generateSignature', ->

    beforeEach ->
      chain.generateSignature()

    it 'sets keylen', ->
      expect(chain.null_move.keylen).toBe 512

    it 'creates a private key', ->
      expect(chain.null_move.private.indexOf '-----BEGIN PRIVATE KEY').toBe 0

    it 'creates a public key', ->
      expect(chain.null_move.public.indexOf '-----BEGIN PUBLIC KEY').toBe 0

  describe 'on loadOpponentPublicKey', ->
    it 'loads the public key', ->
      chain.loadOpponentPublicKey '-----BEGIN PUBLIC KEY-----
MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBALAKMsDZI+CjOG45JOnegwETEB2bx49k
BxD1Sj6EwnAWZx7C0ibZoeWx5GUKlugne2kDjMEBUAGminZQGY6j/EcCAwEAAQ==
-----END PUBLIC KEY-----'
      expect(chain.opp).toBeDefined()
