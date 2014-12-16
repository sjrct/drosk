/*
 * include/util/bfs.h
 * include/kernel/bfs.h
 */

#ifndef _BFS_H_
#define _BFS_H_

/* There should be 16 nodes exactly */
#define BFS_BLOCK_SIZE  512
#define BFS_NAME_LENGTH 16
#define BFS_NODE_COUNT (BFS_BLOCK_SIZE / sizeof(bfs_node_t))

typedef unsigned bfs_block_t;

/* This should be 32 bytes in size */
typedef struct {
	char name[BFS_NAME_LENGTH];
	bfs_block_t block_offset;
	bfs_block_t block_count;
	unsigned res1, res2;
} __attribute__((packed)) bfs_node_t;

typedef bfs_node_t * bfs_directory_t;

#endif
