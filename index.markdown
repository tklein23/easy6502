---
layout: default
---

<h2 id="labyrinth-game">Labyrinth Game</h2>

{% include start.html %}

; _          _                _       _   _        __        ___    _     _  __
;| |    __ _| |__  _   _ _ __(_)_ __ | |_| |__     \ \      / / \  | |   | |/ /
;| |   / _` | '_ \| | | | '__| | '_ \| __| '_ \ ____\ \ /\ / / _ \ | |   | ' /
;| |__| (_| | |_) | |_| | |  | | | | | |_| | | |_____\ V  V / ___ \| |___| . \
;|_____\__,_|_.__/ \__, |_|  |_|_| |_|\__|_| |_|      \_/\_/_/   \_\_____|_|\_\
;                  |___/

; Change direction: W A S D

; $02    => direction (1 => up, 2 => right, 4 => down, 8 => left)
; $10-11 => the current robot position
; $12-13 => the robots target position

{% include labyrinth-walk.html %}
{% include labyrinth-draw.html %}

{% include end.html %}
