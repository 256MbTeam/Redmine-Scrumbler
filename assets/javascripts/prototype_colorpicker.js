var colorPicker=Class.create({
	initialize:function(){
		var args = $A(arguments);
		this.el = $(args[0]);
		this.options = Object.extend({
			previewElement:false,
			inputElement:false,
			eventName: 'click',
			onLoad:function(){return true;},
			onShow:function(){return true;},
			onBeforeShow:function(){return true;},
			onHide:function(){return true;},
			onChange:function(){return true;},
			onSubmit:function(){return true;},
			color: '000000',
			origColor: false,
			livePreview: true,
			hideOnSubmit:true,
			updateOnChange:true,
			flat: false,
			hasExtraInfo:false,
			extraInfo:function(){return true;}
		},args[1]);
		this.ids = {};
		this.fields = [];
		this.current = {}
		this.inAction = false;
		this.charMin = 65;
		this.visible = false;
		this.time = new Date().getTime();
		this.id = 'colorpicker_' + this.time;
		var cp_tpl = '<div class="colorpicker_color"><div><div></div></div></div><div class="colorpicker_hue"><div></div></div><div class="colorpicker_new_color"></div><div class="colorpicker_current_color"></div><div class="colorpicker_hex"><input type="text" maxlength="6" size="6" /></div><div class="colorpicker_rgb_r colorpicker_field"><input type="text" maxlength="3" size="3" /><span></span></div><div class="colorpicker_rgb_g colorpicker_field"><input type="text" maxlength="3" size="3" /><span></span></div><div class="colorpicker_rgb_b colorpicker_field"><input type="text" maxlength="3" size="3" /><span></span></div><div class="colorpicker_hsb_h colorpicker_field"><input type="text" maxlength="3" size="3" /><span></span></div><div class="colorpicker_hsb_s colorpicker_field"><input type="text" maxlength="3" size="3" /><span></span></div><div class="colorpicker_hsb_b colorpicker_field"><input type="text" maxlength="3" size="3" /><span></span></div><div class="colorpicker_submit"></div><div class="colorpicker_extra" style="display:none;"></div><div class="colorpicker_extrafill" style="display:none;"></div>';
		this.cp = $(document.createElement('DIV'));
		this.cp.writeAttribute('id',this.id).addClassName('colorpicker').setStyle({'display':'none'}).insert(cp_tpl);
		if (typeof this.options.color == 'string') {
			this.color = this.HexToHSB(this.options.color);
		} else if (this.color.r != undefined && this.options.color.g != undefined && this.options.color.b != undefined) {
			this.color = this.RGBToHSB(this.options.color);
		} else if (this.options.color.h != undefined && this.options.color.s != undefined && this.options.color.b != undefined) {
			this.color = this.fixHSB(this.options.color);
		} else {
			return this;
		}
		var color_picker = this;

		this.options.origColor = this.options.color;
		
		if (this.options.flat) {
			this.options.hideOnSubmit = false;
			this.cp.setStyle({position: 'relative',display: 'block'});
			this.el.insert({after:this.cp});
			this.cp.show();
		} else {
			document.body.appendChild(this.cp);
			$(this.el).observe(this.options.eventName, this.show.bind(this));
		}
		this.fields = $$('#'+this.id+' input')
		this.fields.each(function(field){
			field.observe('keyup', this.keyUp.bind(this));
			field.observe('change', function(ev){this.change(ev.element());}.bind(this));
			field.observe('blur', this.blur.bind(this));
			field.observe('focus', this.focus.bind(this));
		}.bind(this));
		$$('#'+this.id+' span').each(function(span){span.observe('mousedown', this.downIncrement.bind(this));}.bind(this));
		this.cp.down('div.colorpicker_current_color').observe('click', this.restoreOriginal.bind(this));
		this.selector = this.cp.down('div.colorpicker_color');
		this.selector.observe('mousedown', this.downSelector.bind(this));
		this.selectorIndic = this.selector.down('div').down('div');
		this.hue = this.cp.down('div.colorpicker_hue div');
		this.cp.down('div.colorpicker_hue').observe('mousedown', this.downHue.bind(this));
		this.newColor = this.cp.down('div.colorpicker_new_color');
		this.currentColor = this.cp.down('div.colorpicker_current_color');
		this.submit = this.cp.down('div.colorpicker_submit');
		this.submit.observe('mouseenter', this.enterSubmit.bind(this));
		this.submit.observe('mouseleave', this.leaveSubmit.bind(this));
		this.submit.observe('click', this.clickSubmit.bind(this));
		
		this.extra = this.cp.down('div.colorpicker_extra');
		this.extraInfo = this.cp.down('div.colorpicker_extrafill');
		if(this.options.hasExtraInfo == true){
			this.extra.show();
			this.options.extraInfo(this);
			this.extra.observe('mouseenter',function(ev){ev.element().addClassName('colorpicker_focus');});
			this.extra.observe('mouseleave',function(ev){ev.element().removeClassName('colorpicker_focus');});
			this.extra.observe('click', function(ev){
				var el = this.extraInfo;
				if(el.visible()) el.hide();
				else el.show();
			}.bind(this));
		}
		this.fillRGBFields(this.color);
		this.fillHSBFields(this.color);
		this.fillHexFields(this.color);
		this.setHue(this.color);
		this.setSelector(this.color);
		this.setCurrentColor((this.options.origColor?this.options.origColor:this.color));
		this.setNewColor(this.color);
		if($(this.options.previewElement)) $(this.options.previewElement).setStyle({'backgroundColor':'#'+this.HSBToHex(this.color)});

		//Event.observe(window, "scroll", this.repositionPicker.bindAsEventListener(this));
		this.options.onLoad(this);
		return this;
		
	},
	fillRGBFields:function(hsb) {
		var rgb = this.HSBToRGB(hsb);
		this.fields[1].value = rgb.r;
		this.fields[2].value = rgb.g;
		this.fields[3].value = rgb.b;
	},
	fillHSBFields:function(hsb) {
		this.fields[4].value = parseInt(hsb.h);
		this.fields[5].value = parseInt(hsb.s);
		this.fields[6].value = parseInt(hsb.b);
	},
	fillHexFields:function(hsb){
		this.fields[0].value = this.HSBToHex(hsb).toUpperCase();
	},
	setSelector:function(hsb){
		this.selector.setStyle({'backgroundColor':'#' + this.HSBToHex({h: hsb.h, s: 100, b: 100})});
		this.selectorIndic.setStyle({
			left: parseInt(150 * hsb.s/100, 10)+'px',
			top: parseInt(150 * (100-hsb.b)/100, 10)+'px'
		});
	},
	setHue:function(hsb){
		this.hue.setStyle({'top':parseInt(150 - 150 * hsb.h/360, 10)+'px'});
	},
	setCurrentColor:function(hsb){
		this.currentColor.setStyle({'backgroundColor':'#' + this.HSBToHex(hsb)});
		if(!this.options.origColor) this.options.origColor = hsb;
	},
	setNewColor:function(hsb){
		this.newColor.setStyle({'backgroundColor':'#' + this.HSBToHex(hsb)});
	},
	keyUp:function(ev){
		var pressedKey = ev.charCode || ev.keyCode || -1;
		if ((pressedKey > this.charMin && pressedKey <= 90) || pressedKey == 32) {
			return false;
		}
		if (this.options.livePreview === true) {
			this.change(ev.element());
		}
	},
	change:function(el){
		var col;
		if (el.up().className.indexOf('_hex')!=-1) {
			this.color = col = this.HexToHSB(this.fixHex(el.value));
		} else if (el.up().className.indexOf('_rgb')!=-1) {
			this.color = col = this.RGBToHSB(this.fixRGB({
				r: parseInt(this.fields[1].value, 10),
				g: parseInt(this.fields[2].value, 10),
				b: parseInt(this.fields[3].value, 10)
			}));
		} else {
			this.color = col = this.fixHSB({
				h: parseInt(this.fields[4].value, 10),
				s: parseInt(this.fields[5].value, 10),
				b: parseInt(this.fields[6].value, 10)
			});
		}
		this.setSelector(col);
		this.setHue(col);
		this.setNewColor(col);
		this.options.onChange(this);
		if(this.options.updateOnChange){
			if(this.el.nodeName == 'INPUT') this.el.value = this.HSBToHex(col);
			if($(this.options.inputElement)) $(this.options.inputElement).value = this.HSBToHex(col);
			if($(this.options.previewElement)) $(this.options.previewElement).setStyle({'backgroundColor':'#'+this.HSBToHex(col)});
		}
	},
	blur:function(ev){
		ev.element().up().removeClassName('colorpicker_focus');
	},
	focus:function(ev){
		this.charMin = ev.element().hasClassName('_hex') > 0 ? 70 : 65;
		ev.element().addClassName('colorpicker_focus');
	},
	downIncrement:function(ev){
		var parent = ev.element().up();
		var field = parent.down('input');
		field.focus();
		
		this.current = {
			el: parent.addClassName('colorpicker_slider'),
			max: (parent.className.indexOf('_hsb_h')!=-1)? 360 : ((parent.className.indexOf('_hsb')!=-1)? 100 : 255),
			y: ev.pointerY(),
			field: field,
			val: parseInt(field.value, 10),
			preview: this.options.livePreview					
		};
		this.eventUpIncrement = this.upIncrement.bindAsEventListener(this);
		document.observe("mouseup", this.eventUpIncrement);
		this.eventMoveIncrement = this.moveIncrement.bindAsEventListener(this);
		document.observe("mousemove", this.eventMoveIncrement);
	},
	moveIncrement:function(ev){
		this.current.field.value = Math.max(0, Math.min(this.current.max, parseInt(this.current.val + ev.pointerY() - this.current.y, 10)));
		if(this.current.preview) {
			this.change(this.current.field);
		}
		return false;
	},
	upIncrement:function(ev){
		this.change(ev.element());
		this.current.el.removeClassName('colorpicker_slider');
		this.current.el.down('input').focus();
		if(ev.element().up().className.indexOf('_hsb')!=-1) this.fillRGBFields(this.color);
		else this.fillHSBFields(this.color);
		this.fillHexFields(this.color);
		Event.stopObserving(document, "mouseup", this.eventUpIncrement);
		Event.stopObserving(document, "mousemove", this.eventMoveIncrement);
		return false;
	},
	downHue:function(ev){
		this.current = {
			y: ev.element().cumulativeOffset().top,
			preview: this.options.livePreview
		};
		this.eventUpHue = this.upHue.bindAsEventListener(this);
		document.observe("mouseup", this.eventUpHue);
		this.eventMoveHue = this.moveHue.bindAsEventListener(this);
		document.observe("mousemove", this.eventMoveHue);
	},
	moveHue:function(ev){
		this.fields[4].value = parseInt(360*(150 - Math.max(0,Math.min(150,(ev.pointerY() - this.current.y))))/150, 10)
		this.change(this.fields[4]);
		return false;
	},
	upHue:function(ev){
		this.fillRGBFields(this.color);
		this.fillHexFields(this.color);
		this.fields[4].value = parseInt(360*(150 - Math.max(0,Math.min(150,(ev.pointerY() - this.current.y))))/150, 10)
		this.change(this.fields[4]);
		Event.stopObserving(document, "mouseup", this.eventUpHue);
		Event.stopObserving(document, "mousemove", this.eventMoveHue);
		return false;
	},
	downSelector:function(ev){
		this.current = {
			pos: ev.element().cumulativeOffset(),
			preview:this.options.livePreview
		};
		this.eventUpSelector = this.upSelector.bindAsEventListener(this);
		document.observe("mouseup", this.eventUpSelector);
		this.eventMoveSelector = this.moveSelector.bindAsEventListener(this);
		document.observe("mousemove", this.eventMoveSelector);
	},
	moveSelector:function(ev){
		this.fields[6].value = parseInt(100*(150 - Math.max(0,Math.min(150,(ev.pointerY() - this.current.pos.top))))/150, 10);
		this.fields[5].value = parseInt(100*(Math.max(0,Math.min(150,(ev.pointerX() - this.current.pos.left))))/150, 10);
		this.change(ev.element());
		return false;
	},
	upSelector:function(ev){
		this.moveSelector(ev);
		this.fillRGBFields(this.color);
		this.fillHexFields(this.color);
		Event.stopObserving(document, "mouseup", this.eventUpSelector);
		Event.stopObserving(document, "mousemove", this.eventMoveSelector);
		return false;
	},
	enterSubmit:function(ev){
		ev.element().addClassName('colorpicker_focus');
	},
	leaveSubmit:function(ev){
		ev.element().removeClassName('colorpicker_focus');
	},
	clickSubmit:function(ev){
		var col = this.color;
		this.origColor = col;
		this.setCurrentColor(col);
		if(this.el.nodeName == 'INPUT') this.el.value = this.HSBToHex(col);
		if($(this.options.inputElement)) $(this.options.inputElement).value = this.HSBToHex(col);
		if($(this.options.previewElement)) $(this.options.previewElement).setStyle({'backgroundColor':'#'+this.HSBToHex(col)});
		this.options.onSubmit(this);
		if(this.options.hideOnSubmit) this.hidePicker();
	},
	show:function(ev){
		this.options.onBeforeShow(this);
		this.positionPicker(ev);
		if(this.options.onShow(this)) this.cp.setStyle({display:'block'});
		this.eventHide = this.hide.bindAsEventListener(this);
		document.observe("mousedown", this.eventHide);
		return false;
	},
	hide:function(ev){
		var el = (typeof(ev) == 'object')?ev.element():$(document.body);
		if (!this.isChildOf(this.cp, el)) {
			if(this.options.onHide(this)) this.cp.setStyle({'display':'none'});
			Event.stopObserving(document, "mousedown", this.eventHide);
		}
	},
	isChildOf:function(parentEl, el) {
		if (parentEl == el) {
			return true;
		}
		return $(el).descendantOf(parentEl);
	},
	getViewport:function(){
		return {
			l : document.viewport.getScrollOffsets().left,
			t : document.viewport.getScrollOffsets().top,
			w : document.viewport.getWidth(),
			h : document.viewport.getHeight()
		};
	},
	positionPicker:function(ev){
		var pos = ev.element().cumulativeOffset();
		var viewPort = this.getViewport();
		var top = pos.top + ev.element().getHeight();
		var left = pos.left;
		if (top + 176 > viewPort.t + viewPort.h) {
			top -= ev.element().getHeight() + 176;
		}
		if (left + 356 > viewPort.l + viewPort.w) {
			left -= (356-this.el.getWidth());
		}
		this.cp.setStyle({left: left + 'px', top: top + 'px'});
		
	},
	fixHSB:function(hsb){
		return {
			h: Math.min(360, Math.max(0, hsb.h)),
			s: Math.min(100, Math.max(0, hsb.s)),
			b: Math.min(100, Math.max(0, hsb.b))
		};
	}, 
	fixRGB:function(rgb){
		return {
			r: Math.min(255, Math.max(0, rgb.r)),
			g: Math.min(255, Math.max(0, rgb.g)),
			b: Math.min(255, Math.max(0, rgb.b))
		};
	},
	fixHex:function(hex){
		var len = 6 - hex.length;
		if (len > 0) {
			var o = [];
			for (var i=0; i<len; i++) {
				o.push('0');
			}
			o.push(hex);
			hex = o.join('');
		}
		return hex;
	}, 
	HexToRGB:function(hex){
		var hex = parseInt(((hex.indexOf('#') > -1) ? hex.substring(1) : hex), 16);
		return {r: hex >> 16, g: (hex & 0x00FF00) >> 8, b: (hex & 0x0000FF)};
	},
	HexToHSB:function(hex){
		return this.RGBToHSB(this.HexToRGB(hex));
	},
	RGBToHSB:function(rgb){
		var hsb = {
			h: 0,
			s: 0,
			b: 0
		};
		var min = Math.min(rgb.r, rgb.g, rgb.b);
		var max = Math.max(rgb.r, rgb.g, rgb.b);
		var delta = max - min;
		hsb.b = max;
		if (max != 0) {
			
		}
		hsb.s = max != 0 ? 255 * delta / max : 0;
		if (hsb.s != 0) {
			if (rgb.r == max) {
				hsb.h = (rgb.g - rgb.b) / delta;
			} else if (rgb.g == max) {
				hsb.h = 2 + (rgb.b - rgb.r) / delta;
			} else {
				hsb.h = 4 + (rgb.r - rgb.g) / delta;
			}
		} else {
			hsb.h = -1;
		}
		hsb.h *= 60;
		if (hsb.h < 0) {
			hsb.h += 360;
		}
		hsb.s *= 100/255;
		hsb.b *= 100/255;
		return hsb;
	},
	HSBToRGB:function(hsb){
		var rgb = {};
		var h = Math.round(hsb.h);
		var s = Math.round(hsb.s*255/100);
		var v = Math.round(hsb.b*255/100);
		if(s == 0) {
			rgb.r = rgb.g = rgb.b = v;
		} else {
			var t1 = v;
			var t2 = (255-s)*v/255;
			var t3 = (t1-t2)*(h%60)/60;
			if(h==360) h = 0;
			if(h<60) {rgb.r=t1;	rgb.b=t2; rgb.g=t2+t3}
			else if(h<120) {rgb.g=t1; rgb.b=t2;	rgb.r=t1-t3}
			else if(h<180) {rgb.g=t1; rgb.r=t2;	rgb.b=t2+t3}
			else if(h<240) {rgb.b=t1; rgb.r=t2;	rgb.g=t1-t3}
			else if(h<300) {rgb.b=t1; rgb.g=t2;	rgb.r=t2+t3}
			else if(h<360) {rgb.r=t1; rgb.g=t2;	rgb.b=t1-t3}
			else {rgb.r=0; rgb.g=0;	rgb.b=0}
		}
		return {r:Math.round(rgb.r), g:Math.round(rgb.g), b:Math.round(rgb.b)};
	},
	RGBToHex:function(rgb){
		var hex = [
			rgb.r.toString(16),
			rgb.g.toString(16),
			rgb.b.toString(16)
		];
		hex.each(function(val,nr) {
			if(val.length == 1){
				hex[nr] = '0' + val;
			}
		});
		return hex.join('');
	},
	HSBToHex:function(hsb){
		return this.RGBToHex(this.HSBToRGB(hsb));
	},
	restoreOriginal:function(){
		var col = this.options.origColor;
		this.color = col;
		this.fillRGBFields(col);
		this.fillHexFields(col);
		this.fillHSBFields(col);
		this.setSelector(col);
		this.setHue(col);
		this.setNewColor(col);
	},
	showPicker: function() {
		this.cp.show();
	},
	hidePicker: function() {
		this.cp.hide();
	},
	setColor: function(col) {
		if (typeof col == 'string') {
			col = this.HexToHSB(col);
		} else if (col.r != undefined && col.g != undefined && col.b != undefined) {
			col = this.RGBToHSB(col);
		} else if (col.h != undefined && col.s != undefined && col.b != undefined) {
			col = fixHSB(col);
		} else {
			return this;
		}
		this.color = col;
		this.origColor = col;
		this.fillRGBFields(col);
		this.fillHSBFields(col);
		this.fillHexFields(col);
		this.setHue(col);
		this.setSelector(col);
		this.setCurrentColor(col);
		this.setNewColor(col);
	}
});