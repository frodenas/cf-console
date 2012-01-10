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
    'Value not equal with the $1 field.',
    function(input) {
	  var name = input.attr('data_equals');
	  var field = this.getInputs().filter('[name=' + name + ']');
	  return input.val() == field.val() ? true : [name];
    }
  );
});