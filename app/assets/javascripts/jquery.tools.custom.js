$(function() {
  $.tools.validator.addEffect(
    'below_field_error',
    function(errors, event) {
	  $.each(errors, function(index, error) {
        error.input.addClass('form-field-invalid');
        var siblings = error.input.siblings('.form-field-error');
        siblings.empty();
        siblings.append(error.messages[0]);
        siblings.show();
      });
    },
    function(inputs) {
      inputs.removeClass('form-field-invalid');
      var siblings = inputs.siblings('.form-field-error');
      siblings.hide();
    }
  );
  $.tools.validator.fn(
    '[data_equals]',
    function(input) {
	  var name = input.attr('data_equals');
      var name_label = input.attr('data_equals_label');
	  var field = this.getInputs().filter('[name=' + name + ']');
	  return input.val() == field.val() ? true : {
	    en: 'Value not equal with the ' + name_label + ' field',
        es: 'El valor de este campo no es igual al valor del campo ' + name_label,
	    ca: 'El valor d\'aquest camp no es igual al valor del camp ' + name_label
      };
    }
  );
  $.tools.validator.localize("es", {
    '*'  		: 'Por favor, corrija este valor',
    ':email'    : 'Por favor, introduzca una dirección de email correcta',
    ':number'   : 'Por favor, introduzca un valor numérico',
    ':url'      : 'Por favor, introduzca una URL correcta',
    '[max]'     : 'Por favor, introduzca un valor más pequeño que $1',
    '[min]'     : 'Por favor, introduzca un valor más grande que $1',
    '[required]': 'Por favor, rellene este campo obligatorio'
  });
  $.tools.validator.localize("ca", {
    '*'  		: 'Si us plau, corregeixi aquest valor',
    ':email'    : 'Si us plau, introdueixi una adreça de email correcte',
    ':number'   : 'Si us plau, introdueixi un valor numèric',
    ':url'      : 'Si us plau, introdueixi una URL correcte',
    '[max]'     : 'Si us plau, introdueixi un valor més gran que $1',
    '[min]'     : 'Si us plau, introdueixi un valor més petit que $1',
    '[required]': 'Si us plau, ompli aquest camp obligatori'
  });
});