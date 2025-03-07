return {
	require('adhd-reader').setup {
		wpm = 300,
		font_size = 24,
		word_padding = 10,
		highlight = { word_start = true, consonants = true, morphemes = true },
	},
	vim.keymap.set('n', '<leader>ar', '<cmd>ADHDRead<cr>', { desc = '[A]DHD [R]ead' }),
}
