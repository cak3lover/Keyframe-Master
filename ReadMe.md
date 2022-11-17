# Keyframe Master -v1.0

Tired of adding the same keyframes for multiple nodes? I got you covered! <br>
With this plugin you can automate the process so you can focus more on your animations!

(Testing on v.3.5.stable.mono.official)

<br>

## Setup
To get started, Paste the `Keyframe Master` folder inside the addons folder & check enabled ( [more on addons](https://youtu.be/Ca2FcVb2lBk?t=124) )

![enable](Images/enable.png)

<br>

## How to use?

Let us take this setup as an example

![default_setup](Images/default_setup.png)

<br>

## Adding Multiple Keyframes

I. Open the desired animation in the bottom panel (in this case 'New Anim') & set the timebar to the desired time (in this case 0.4)

![open_animation](Images/open_animation.png)


II. Select the multiple nodes for which you'd like to add the keyframes (in this case 'Icon' & 'Icon2')

![select_nodes](Images/select_nodes.png)

III. Click on `Keyframe Master` button & type in the property you would like to add (in this case 'position')


![set_addkey_keyframemaster](Images/set_addkey_keyframemaster.png)

and press add or remove to insert/delete a column of keyframes into/from the animation

![added_keyframes](Images/added_keyframes.png)

## Moving Multiple Keyframes

Similarly, you can also move keyframes to the desired time stamp (in this case 0.1)

![moving_keyframes](Images/moving_keyframes.png)

after pressing `Move` you can see that the entire column has moved to the timestamp 0.1

![moved_keyframes](Images/moved_keyframes.png)

If you press `Duplicate` instead then the keyframes would get duplicated at timestamp 0.1

![duplicated_keyframes](Images/duplicated_keyframes.png)

I hope this helps & speeds up your workflow!

<br>

### Known Issues

<ul>
    <li>Undo-Redo not available</li>
    <li>Gives `Condition "key == -1" is true. Returned: false` Error upon moving</li>
</li>
