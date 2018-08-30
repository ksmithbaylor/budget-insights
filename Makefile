start:
	@node src/server &
	@yarn elm reactor &
	@sleep 0.2
	@browser-sync start --proxy "localhost:8000" --files "src/**/*" --no-notify

test:
	@yarn elm-test

test-watch:
	@observe 'yarn elm-test' src tests

build:
	@yarn -s elm make src/Main.elm --output elm.js --optimize
	@du -h elm.js
	@echo "$$(yarn -s gzip-size elm.js)\telm.js.gz"
	@yarn -s uglifyjs elm.js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters=true,keep_fargs=false,unsafe_comps=true,unsafe=true,passes=2' --output=elm.min.js
	@yarn -s uglifyjs elm.min.js --mangle --output=elm.min.js
	@du -h elm.min.js
	@echo "$$(yarn -s gzip-size elm.min.js)\telm.min.js.gz"
