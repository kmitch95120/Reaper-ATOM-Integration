# Reaper-ATOM-Integration #
Exploring the integration of the Presonus ATOM Pad Controller with the Reaper Digital Audio Workstation

## Background ##

I first saw the [Presonus ATOM](https://www.presonus.com/products/atom) in a YouTube video by Robert Mathijs from [Quest for Groove](https://questforgroove.com/). I was just starting to look for a replacement for my two year old Akai MPD218 that had just started developing the dreaded double-trigger problem. Robert recommended the ATOM as a top choice for an entry level pad controller.

After watching a YouTube review of the Presonus ATOM, I was immediately intrigued by how tight it was integrated with Presonus Studio One 4.  The problem was my DAW of choice is [Reaper](https://www.reaper.fm). I have nothing against Studio One. In fact, I find it a very capable DAW. It's just not the DAW I've been using for the last nine years.

This repo is a compilation of information and code I've discovered, compiled, and developed to help integrate the ATOM with Reaper.

## Exploring and the Tools I Use ##

My platform of choice for working with MIDI is a Mac.  The tools I use are both free and open source: [MIDI Monitor](https://github.com/krevis/MIDIApps) and [SendMIDI](https://github.com/gbevin/SendMIDI).

MIDI Monitor is written for the Mac but I'm sure there are similar tools available for other platforms.  The one feature of MIDI Monitor that is crucial is the ability to "spy" on MIDI output destinations.  In other words, you can see what a MIDI device is sending AND also what is being sent to the MIDI device. The one feature I wish MIDI Monitor had was the ability to display the raw MIDI messages along side the human readable messages, since it's the raw data that's needed for Reaper.

SendMIDI has pre-built binaries available for several platforms. I run SendMIDI with simple bash shell scripts just to reduce typing and to keep a consistent record of what I've tried out and what works or what doesn't.

Everything related to my exploration and experimentation can be found in the "Explore" directory of the repo.

## Code abd Documentation ##

All of the Reaper scripts I create can be found in the ReaScript directory.

All of the formal documentation I create can be found in the Docs directory.
