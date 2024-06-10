return {
	{
		'gera2ld/ai.nvim',
		dependencies = 'nvim-lua/plenary.nvim',
		opts = {
			--api_key = 'YOUR_GEMINI_API_KEY', -- or read from env: `api_key = os.getenv('GEMINI_API_KEY')`
			-- The locale for the content to be defined/translated into
			api_key = os.getenv('GEMINI_API_KEY'),
			locale = 'en',
			-- The locale for the content in the locale above to be translated into
			alternate_locale = 'pt-br',
			-- Define custom prompts here, see below for more details
			prompts = {},
		},
		event = 'VeryLazy',
	},
}
