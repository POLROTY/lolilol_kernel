/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   kernel.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rpol <marvin@42.fr>                        +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/17 01:48:21 by rpol              #+#    #+#             */
/*   Updated: 2025/05/17 01:48:30 by rpol             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */
#include "include/stdint.h"
#include "include/string.h"

static uint16_t	*const VIDEO = (uint16_t *)0xB8000;
static uint8_t	row = 0;
static uint8_t	col = 0;

static void	putc(char c)
{
	if (c == '\n')
	{
		col = 0;
		++row;
		return ;
	}
	VIDEO[row * 80 + col] = (uint16_t)c | 0x0F00;
	if (++col >= 80)
	{
		col = 0;
		++row;
	}
}

void	print(const char *s)
{
	while (*s)
		putc(*s++);
}

void	kernel_main(void)
{
	print("42               * A Lolilol kernel by hspriet & rpol");
	while (1)
		__asm__ __volatile__("hlt");
}
