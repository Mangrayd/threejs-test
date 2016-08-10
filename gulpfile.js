'use strict';

var gulp    = require('gulp'),
	coffee  = require('gulp-coffee'),
	plumber = require('gulp-plumber'),
	concat  = require('gulp-concat'),
	maps    = require('gulp-sourcemaps');

// COFFEE task
gulp.task('coffee', function() {
	gulp.src('coffee/*.coffee')
		.pipe(maps.init())
		.pipe(plumber())
		.pipe(coffee({ bare:true }))
		.pipe(concat('main.js'))
		.pipe(maps.write())
		.pipe(gulp.dest('js/'))
});

gulp.task('watch', function(){
	gulp.watch('coffee/*.coffee', ['coffee']);
});