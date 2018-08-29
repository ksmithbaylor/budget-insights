start:
	@node src/server &
	@yarn elm reactor &
	@sleep 0.2
	@browser-sync start --proxy "localhost:8000" --files "src/**/*" --no-notify

test:
	@yarn elm-test

test-watch:
	@observe 'yarn elm-test' src tests