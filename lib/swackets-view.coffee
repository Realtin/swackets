{Range, Point, CompositeDisposable} = require 'atom'
$ = require 'jquery'

module.exports =
class SwacketsView

    intervalID = null

    constructor: ->
        @sweatify()

        @subscriptions = new CompositeDisposable
        @subscriptions.add atom.workspace.onDidChangeActivePaneItem =>
            @sweatify()
            editor = atom.workspace.getActiveTextEditor()
            return unless editor
            @subscriptions.add editor.onDidChange(@sweatify)

        intervalID = setInterval =>
            @sweatify()
        , 100

        editor = atom.workspace.getActiveTextEditor()
        return unless editor
        @subscriptions.add editor.onDidChange(@sweatify)

        @subscriptions.add atom.commands.add 'atom-workspace', 'swackets:toggle': => @toggle()

    destroy: ->
        clearInterval(intervalID)
        @subscriptions.dispose()



    sweatify: ->
        config = atom.config.get('swackets')

        curlyness = 0 if config.curlies
        roundyness = 0 if config.parenthesis

        colors = ['#ff3333']
        colors = colors.concat(config.colors)

        setTimeout ->

            lineGroups = $("atom-text-editor.is-focused::shadow .lines > div:not(.cursors) > div")
            numLineGroups = lineGroups.toArray().length
            firstGroup = undefined;

            while numLineGroups >= 0
                singleGroup = $(lineGroups).filter -> $(this).css('zIndex') == (''+numLineGroups)

                if (!firstGroup and singleGroup.length >= 1)
                    firstLine = $(singleGroup).children(".line").first().attr('data-screen-row')
                    range = new Range(new Point(0, 0), new Point(Number(firstLine), 0))
                    editor = atom.workspace.getActiveTextEditor()
                    return unless editor
                    northOfTheScroll = editor.getTextInBufferRange(range)
                    unseenLength = northOfTheScroll.length

                    curChar = 0
                    curSpeechChar = undefined #TODO omit comments and speechmarks (HARD)
                    while (curChar < unseenLength)
                      if config.curlies
                        if (northOfTheScroll[curChar] == '{')
                            curlyness++
                        else if (northOfTheScroll[curChar] == '}')
                            curlyness = Math.max.apply @, [(curlyness-1), 0]
                      if config.parenthesis
                        if (northOfTheScroll[curChar] == '(')
                            roundyness++
                        else if (northOfTheScroll[curChar] == ')')
                            roundyness = Math.max.apply @, [(roundyness-1), 0]

                      curChar++

                    firstGroup = true
                    ####DONE WITH PRE-BUFFER GUESSTIMATION####

                $(singleGroup).find('span').each (index, element) =>

                    if config.curlies
                      if ($(element).html()[0] == '{' || $(element).html()[1] == '{')
                          curlyness++
                          sweatcap = Math.max.apply @, [curlyness, 0]
                          sweatcap = Math.min.apply @, [sweatcap, colors.length - 1]
                          $(element).css('color', colors[sweatcap])

                      if ($(element).html()[0] == '}' || $(element).html()[1] == '}')
                          sweatcap = Math.max.apply @, [curlyness, 0]
                          sweatcap = Math.min.apply @, [sweatcap, colors.length - 1]
                          $(element).css('color', colors[sweatcap])

                          curlyness = Math.max.apply @, [(curlyness-1), 0]

                    if config.parenthesis
                      if ($(element).html()[0] == '(' || $(element).html()[1] == '(')
                          roundyness++
                          sweatcap = Math.max.apply @, [roundyness, 0]
                          sweatcap = Math.min.apply @, [sweatcap, colors.length - 1]
                          $(element).css('color', colors[sweatcap])

                      if ($(element).html()[0] == ')' || $(element).html()[1] == ')')
                          sweatcap = Math.max.apply @, [roundyness, 0]
                          sweatcap = Math.min.apply @, [sweatcap, colors.length - 1]
                          $(element).css('color', colors[sweatcap])

                          roundyness = Math.max.apply @, [(roundyness-1), 0]


                numLineGroups-- #END OF WHILE#
        , 24
