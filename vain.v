module vain

import regex

type FNErrorCallback = fn (arg_1 string)

type FNString2String = fn (arg_1 string) string

struct LexRule {
	id       string
	str_rule string
	callback FNString2String
	is_regex bool
	re       regex.RE
}

struct Lexer {
	rules        []LexRule
	err_callback FNErrorCallback
mut:
	pos          int
	input        string
}

pub fn (mut lexer Lexer) next() ?(string, string) {
	if lexer.pos == lexer.input.len {
		return none
	}
	for rule in lexer.rules {
		if rule.is_regex {
			mut regex := rule.re
			start, end := regex.match_string(lexer.input[lexer.pos..])
			if start != 0 {
				continue
			}
			token := rule.callback(lexer.input[lexer.pos + start..lexer.pos + end])
			lexer.pos += end
			return rule.id, token
		} else {
			read := lexer.input[lexer.pos..lexer.pos + rule.str_rule.len]
			if rule.str_rule != read {
				continue
			}
			token := rule.callback(read)
			lexer.pos += rule.str_rule.len
			return rule.id, token
		}
	}
	lexer.err_callback(lexer.input[lexer.pos..])
}

fn do_nothing(str string) string {
	return str
}

pub fn literal(tok_id, str string) LexRule {
	return LexRule{
		id: tok_id
		str_rule: str
		callback: do_nothing
		is_regex: false
	}
}

pub fn literal_callback(tok_id, str string, cb FNString2String) LexRule {
	return LexRule{
		id: tok_id
		str_rule: str
		callback: cb
		is_regex: false
	}
}

fn regexstring2re(restring string) regex.RE {
	re, err, err_pos := regex.regex(restring)
	if err != 0 {
		panic('invalid regex $restring at position $err_pos, errcode: $err')
	}
	return re
}

pub fn regex(tok_id, str string) LexRule {
	return LexRule{
		id: tok_id
		str_rule: str
		callback: do_nothing
		is_regex: true
		re: regexstring2re(str)
	}
}

pub fn regex_callback(tok_id, str string, cb FNString2String) LexRule {
	return LexRule{
		id: tok_id
		str_rule: str
		callback: cb
		is_regex: true
		re: regexstring2re(str)
	}
}

pub fn make_lexer(input string, rules []LexRule, err_cb FNErrorCallback) Lexer {
	return Lexer{
		rules: rules
		err_callback: err_cb
		pos: 0
		input: input
	}
}
