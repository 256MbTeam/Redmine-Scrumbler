var TinyColorChooser = Class.create({
    initialize:function(input_id, options){
        this.options = Object.extend({
            element_classname: "color-chooser-element",
            popup_classname: "color-chooser-popup",
            preview_classname: 'color-chooser-preview',
            default_color: "fff",
            popup_width: "88px",
            popup_height: "43px",
            colors: ["fff", "aaa", "faa","ffa","faf","afa","aff", "aaf"]
        }, options);
        
        
        var input_filed = $(input_id);
   
        input_filed.value = input_filed.value || this.options.default_color
        var preview = this.createPreview(input_filed, this.options);
        
        var chooser = this.createPopup(input_filed, preview, this.options);
        
        $(document).observe("click", function(event){
     
            if(preview != event.target){
                
                if(chooser.visible()){
                    chooser.hide();
                }
            }else
            {
                chooser.toggle();      
            }
            return;
        });
        
        var parent = input_filed.parentNode;
        parent.appendChild(preview);
        parent.appendChild(chooser);
    },
    setValue: function(value) {

        this.input_field.value = this.value;
    },
    createPreview: function(input_field, options){
        var preview = new Element('div', {
            'class': this.options.preview_classname
        });
        preview.setStyle({
            background: "#"+(input_field.value)
        });
        return preview;      
    },
    createPopup: function(input_filed, preview, options){
        var popup = new Element('div',{
            'class': options.popup_classname
        });
        popup.setStyle({
            display: 'none',
            width: options["popup_width"],
            height: options["popup_height"]
        });
        
        options.colors.each(function(color){
            var color_field = new Element('div',{
                'class': options.element_classname
            });
            color_field.setStyle({
                background: "#"+color
            });
            color_field.observe("click", function(event){
                preview.setStyle({
                    background: "#"+color
                });
                input_filed.value = color;
            });
            popup.appendChild(color_field);
        });
        return popup;
    }
});
