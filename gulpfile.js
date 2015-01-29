var gulp = require('gulp');
var $ = require('gulp-load-plugins')();

gulp.task('default', function() {
  // place code for your default task here
});

gulp.task('lint', function() {
  return gulp.src('./public/assets/js/*.js')
   .pipe($.jshint())
   .pipe($.jshint.reporter('jshint-stylish'))
   .pipe($.jshint.reporter('fail'));
});
