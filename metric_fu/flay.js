              var g = new Bluff.Line('graph', "1000x600");
      g.theme_37signals();
      g.tooltips = true;
      g.title_font_size = "24px"
      g.legend_font_size = "12px"
      g.marker_font_size = "10px"

        g.title = 'Flay: duplication';
        g.data('flay', [357,367,367]);
        g.labels = {"0":"4/28","1":"4/30","2":"5/4"};
        g.draw();
