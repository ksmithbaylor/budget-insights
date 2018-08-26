start:
	@elm reactor &
	@sleep 0.2
	@browser-sync start --proxy "localhost:8000" --files "src/**/*.elm" --no-notify