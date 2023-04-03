# Hexagram

Hexagram is a live effect that replays samples and grains from the past to create an ambient texture from an input source. It's different to [Granular](https://orllewin.github.io/playdate/granular/) in that it samples live audio and can only be used with headphones or a suitable live input and output using [TRRS](https://help.play.date/hardware/supported-inputs/). It augments the incoming signal rather than acting as a standalone instrument like Granular. Hexagram is also less granular than... Granular; all effects are global, it's a smaller simpler program with just one screen.

The Playdate doesn't support pass-through audio. If using Hexagram in a music setup the source signal should be split and joined again in a mixer, you'll need a TRRS adapter. 

```
                             +------------+        +-----------+
+----------------+           |            |        |           |       /
|                |       ----|  PLAYDATE  |--------|   MIXER   |      / 
|  SOURCE/SYNTH  ------/     |            |        |           |---- | OUT
|                |     \     +------------+        |           |      \ 
+----------------+      \                          |           |       \
                         \_________________________|           |
                                                   +-----------+
```



