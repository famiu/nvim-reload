if exists('g:loaded_nvim_reload') | finish | endif

if !has('nvim-0.5')
    echohl Error
    echomsg "Reload.nvim is only available for Neovim versions 0.5 and above"
    echohl clear
    finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! Reload lua require('nvim-reload').Reload()
command! Restart lua require('nvim-reload').Restart()

let g:loaded_nvim_reload = 1

let &cpo = s:save_cpo
unlet s:save_cpo

