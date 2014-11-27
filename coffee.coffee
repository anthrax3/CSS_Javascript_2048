window.onload = ->
	"use strict"
	y = x = tab = score = win = timer = eventTimer = tabMove = moved = undefined
	vector =
		37: [-1, 0]
		38: [0, -1]
		39: [1, 0]
		40: [0, 1]

	initGame = ->
		if localStorage.getItem("grid")
			tab = JSON.parse(localStorage.getItem("grid"))
			timer = JSON.parse(localStorage.getItem("timer"))
			score = parseInt(localStorage.getItem("score"))
			win = parseInt(localStorage.getItem("win"))
		else
			tab = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]
			timer = { seconde: 0, minute: 0, heure: 0}
			score = win = 0
			spawnNumber()
			spawnNumber()
		displayGrid()
		eventTimer = setInterval(chronometre, 1000)

	displayGrid = ->
		cells = document.getElementById("grid")
		cells.innerHTML = "<div><h3 id=\"score\">score: " + score + "</h3><h3 id=\"timer\">" + str_pad(timer.heure) + ":" + str_pad(timer.minute) + ":" + str_pad(timer.seconde) + "</h3></div>"
		tab.forEach (element, y) ->
			tab[y].forEach (element, x) ->
				cell = { x: x, y: y }
				number = if (cellIsEmpty(cell)) then "" else getTile(cell).value
				cells.innerHTML += "<div class=\"cell tile-" + color(number) + "\">" + number + "</div>"

		shareButton()
		cells.innerHTML += "<h3 id=\"restart\">Recommencer</h3>"

		document.getElementById("restart").onclick = ->
			window.clearInterval eventTimer
			localStorage.clear()
			initGame()

		cells.appendChild document.createTextNode("Tu as gagné")  if win is 1

		if win is -1
			window.clearInterval eventTimer
			cells.appendChild document.createTextNode("Tu as perdu")

	color = (nbr) ->
		return "0"  if nbr is ""
		return "super"  if nbr > "2048"
		nbr

	cellIsEmpty = (cell) ->
		tab[cell.y][cell.x] is 0

	getTile = (cell) ->
		if cellIsEmpty(cell) then null else { x: cell.x, y: cell.y, value: tab[cell.y][cell.x] or 2 }

	gridIsFull = ->
		tab.forEach (element, y) ->
			return false  if tab[y].indexOf(0) isnt -1
		true

	checkLimit = (position) ->
		position.x >= 0 and position.x < tab.length and position.y >= 0 and position.y < tab.length

	spawnNumber = ->
		loop
			x = Math.floor(Math.random() * tab.length)
			y = Math.floor(Math.random() * tab.length)
			if tab[y][x] is 0
				tab[y][x] = (if Math.random() < 0.9 then 2 else 4)
				break

	cellAlreadyMove = (cell) ->
		tabMove[cell.y][cell.x] is 1

	islost = ->
		count = 0
		for y in [0...tab.length]
			for x in [0...tab.length]
				right = left = up = down = false
				return false  if tab[x][y] is 0
				if tab[x][y] isnt 0
					up = true  if tab[x][y + 1] isnt 0 and tab[x][y + 1] isnt tab[x][y]
					down = true  if tab[x][y - 1] isnt 0 and tab[x][y - 1] isnt tab[x][y]
					right = true  if (x is 3) or (x + 1 < 4 and tab[x + 1][y] isnt 0 and tab[x + 1][y] isnt tab[x][y])
					left = true  if (x is 0) or (x - 1 >= 0 and tab[x - 1][y] isnt 0 and tab[x - 1][y] isnt tab[x][y])
					count++  if up is true and down is true and right is true and left is true
					return true  if count >= 16
		false

	move = (x, y, dir) ->
		cell = { x: x, y: y }
		tile = getTile(cell)
		if tile
			after = 0
			before = undefined
			loop
				before = cell
				cell = { x: before.x + dir[0], y: before.y + dir[1] }
				break unless checkLimit(cell) and cellIsEmpty(cell)
			dir = { moreFarAway: before, after: cell }

			after = getTile(dir.after)  if checkLimit(dir.after)
			if after.value is tile.value and not cellAlreadyMove(dir.after) # fusion
				tabMove[dir.after.y][dir.after.x] = 1 # tag de fusion
				tab[tile.y][tile.x] = 0 # suppression de la case
				tab[after.y][after.x] = tile.value * 2 # fusion de la case
				score += tile.value * 2
				win = 1  if tile.value * 2 is 2048
			else # déplacement
				tab[tile.y][tile.x] = 0
				tab[dir.moreFarAway.y][dir.moreFarAway.x] = tile.value

	shifts = (dir) ->
		rstate = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]

		tab.forEach (element, y) ->
			tab[y].forEach (element, x) ->
				rstate[y][x] = tab[y][x]

		rangex = [0, 1, 2, 3]
		rangey = [0, 1, 2, 3]
		tabMove = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]
		moved = false
		rangex.reverse()  if dir[0] is 1
		rangey.reverse()  if dir[1] is 1
		rangey.forEach (y) ->
			rangex.forEach (x) ->
				move x, y, dir

		spawnNumber()  unless JSON.stringify(tab) is JSON.stringify(rstate)
		win = -1  if islost()
		displayGrid()
		localStorage.setItem "grid", JSON.stringify(tab)
		localStorage.setItem "score", score
		localStorage.setItem "win", win

	chronometre = ->
		timer.seconde++
		if timer.seconde > 59
			timer.seconde = 0
			timer.minute++
		if timer.minute > 59
			timer.minute = 0
			timer.heure++
		localStorage.setItem "timer", JSON.stringify(timer)
		document.getElementById("timer").innerHTML = str_pad(timer.heure) + ":" + str_pad(timer.minute) + ":" + str_pad(timer.seconde)

	shareButton = ->
		share = document.getElementById("share")
		share.innerHTML = "<a target=\"_blank\" title=\"Twitter\" href=\"https://twitter.com/share?url=" + document.URL + "&text=J'ai joué à 2048 et j'ai fait un score de " + score + "\" rel=\"nofollow\" onclick=\"javascript:window.open(this.href, '', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=400,width=700');return false;\"><img src=\"http://korben.info/wp-content/themes/korben2013/hab/twitter_icon.png\" alt=\"Twitter\" /></a><br><a target=\"_blank\" title=\"Facebook\" href=\"https://www.facebook.com/dialog/feed?app_id=145634995501895&display=popup&link=" + document.URL + "&redirect_uri=https://developers.facebook.com/tools/explorer\" rel=\"nofollow\" onclick=\"javascript:window.open(this.href, '', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=500,width=700');return false;\"><img src=\"http://korben.info/wp-content/themes/korben2013/hab/facebook_icon.png\" alt=\"Facebook\" /></a><br><a target=\"_blank\" title=\"Google +\" href=\"https://plus.google.com/share?url=" + document.URL + "&hl=fr\" rel=\"nofollow\" onclick=\"javascript:window.open(this.href, '', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=450,width=650');return false;\"><img src=\"http://korben.info/wp-content/themes/korben2013/hab/gplus_icon.png\" alt=\"Google Plus\" /></a><br><a target=\"_blank\" title=\"Linkedin\" href=\"https://www.linkedin.com/shareArticle?mini=true&url=" + document.URL + "&title=2048 c'est de la balle\" rel=\"nofollow\" onclick=\"javascript:window.open(this.href, '','menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=450,width=650');return false;\"><img src=\"http://korben.info/wp-content/themes/korben2013/hab/linkedin_icon.png\" alt=\"Linkedin\" /></a>"

	str_pad = (n) ->
		if (n < 10) then "0" + n else n

	window.addEventListener "keydown", (event) ->
		shifts vector[event.keyCode]  if vector[event.keyCode]

	initGame()