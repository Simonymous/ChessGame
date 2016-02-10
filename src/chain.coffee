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

Crypto = require 'crypto'
NodeRSA = require 'node-rsa'

module.exports =
  class Chain
    constructor: ({key}) ->
      @hash = Crypto.createHash 'sha256'
      @hash.update(key)
      @key = null
      @opp = null
      @null_move =
        keylen: 0
        private: ''
        public: ''
        h: @hash.digest 'hex'
      @last = @null_move
      @onerror = null

    generateSignature: (keylen = 512) ->
      @key = new NodeRSA(b: keylen)
      @null_move.keylen = @key.getKeySize()
      @null_move.private = @key.exportKey 'pkcs8-private-pem'
      @null_move.public = @key.exportKey 'pkcs8-public-pem'

    loadOpponentPublicKey: (key) ->
      @opp = new NodeRSA
      @opp.importKey key, 'pkcs8-public-pem'

    getPublicKey: ->
      @null_move.public

    signTransmission: (move) ->
      move + '-' + @key.sign(move + '-' + @last.h, 'hex')

    hashTransmission: (signed_move) ->
      @hash.update(signed_move)
      signed_move + '-' + @hash.digest 'hex'

    hashChain: (move, xor) ->
      @hash.update(move + '-' + xor + '-' + @last.h)
      @hash.digest 'hex'

    verifyTransmissionHash: (move, signature, hash) ->
      hash is @hashTransmission(move + '-' + signature)

    verifyTransmissionSignature: (move, signature) ->
      @opp.verify move + '-' + @last.h, signature, 'hex'

    verify: (move, signature, hash) ->
      unless @verifyTransmissionHash move, signature, hash
        @onerror?('Transmission Hash Mismatch', move, signature, hash)
        return null

      unless @verifyTransmissionSignature move, signature
        @onerror?('Transmission Signature Mismatch', move, signature, hash)
        return null

      return @hashTransmission(@signTransmission(move))

    xor: (o, s) ->
      if o.length isnt s.length
        @onerror?('Signature Length Mismatch', o, s)
        return null
      i = 0
      r = ''
      while i isnt o.length
        c1 = o.charCodeAt i
        c2 = s.charCodeAt i
        r += Number(c1 ^ c2).toString(16)
        i = i + 1
      return r

    addToChain: (move, signature) ->
      o = signature
      s = @signTransmission move
      @last.next =
        move: move
        o: o
        s: s
        h: @hashChain move, @xor(o, s)
        prev: @last
        next: null
      @last = @last.next
