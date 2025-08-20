import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

/**
 * Utilitaire pour combiner les classes CSS avec clsx et tailwind-merge
 */
export function cn(...inputs: (string | undefined | null | false)[]) {
  return twMerge(clsx(inputs));
} 