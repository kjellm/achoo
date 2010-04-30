              var g = new Bluff.Line('graph', "1000x600");
      g.theme_37signals();
      g.tooltips = true;
      g.title_font_size = "24px"
      g.legend_font_size = "12px"
      g.marker_font_size = "10px"

        g.title = 'Reek: code smells';
        g.data('ClassVariable', [1,1])
g.data('ControlCouple', [4,4])
g.data('Duplication', [55,55])
g.data('IrresponsibleModule', [30,30])
g.data('LargeClass', [1,1])
g.data('LongMethod', [31,31])
g.data('LongParameterList', [3,3])
g.data('LowCohesion', [55,55])
g.data('NestedIterators', [8,8])
g.data('SimulatedPolymorphism', [1,1])
g.data('UncommunicativeName', [55,55])

        g.labels = {"0":"4/28","1":"4/30"};
        g.draw();
