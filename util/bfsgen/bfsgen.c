#include <bfs.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define SUPERBLOCK_NAME "bfs"

void help(void)
{
	puts(
		"bfsgen:\n"
		"    Generates a boot file system image.\n"
		"    Note that an actual filename of '" SUPERBLOCK_NAME "' specifies the superblock, and is required.\n"
		"\n"
		"usage:\n"
		"    bfsgen [options] [bfs-file=actual-file] ...\n"
		"\n"
		"options:\n"
		"    -h        - displays this useful information.\n"
		"    -o[file]  - outputs image to a file.\n"
		"    -b[block] - the starting block address to use.\n"
		"\n"
	);
}

bfs_block_t count_blocks(const char * name)
{
	FILE * f;
	size_t s;

	if (strcmp(name, SUPERBLOCK_NAME)) {
		f = fopen(name, "rb");
		if (f == NULL) {
			fprintf(stderr, "error: Could not open file '%s'.\n", name);
			exit(EXIT_FAILURE);
		}
		fseek(f, 0, SEEK_END);
		s = ftell(f);
		fclose(f);
	} else {
		return 1;
	}

	return (s % BFS_BLOCK_SIZE) ? (s / BFS_BLOCK_SIZE + 1) : (s / BFS_BLOCK_SIZE);
}

void write_file(const char * name, FILE * f)
{
	int i, c;
	FILE * g;

	g = fopen(name, "rb");
	if (g == NULL) {
		fprintf(stderr, "error: Could not open file '%s'.\n", name);
		exit(EXIT_FAILURE);
	}

	for (i = 0; EOF != (c = fgetc(g)); i++) fputc(c, f);
	fclose(g);
	for (; i % BFS_BLOCK_SIZE; i++) fputc(0, f);
}

int main(int argc, char ** argv)
{
	FILE * f;
	int i, j = 0, wrotesb = 0;
	char * name;
	char * output = "bfs.iso";
	char * files[BFS_NODE_COUNT];
	bfs_block_t offset = 0, start_block = 0;
	bfs_node_t nodes[BFS_NODE_COUNT];

	/* assert the validity of the bfs system */
	assert(BFS_NODE_COUNT * sizeof(bfs_node_t) == BFS_BLOCK_SIZE);

	/* zero the bfs nodes to start with */
	memset(nodes, 0, sizeof(bfs_node_t) * BFS_NODE_COUNT);

	/* parse the arguments and generate the system */
	for (i = 1; i < argc; i++) {
		if (argv[i][0] == '-') {
			/* parse options */
			switch (argv[i][1]) {
			case 'b':
				start_block = atol(argv[i] + 1);
				break;
			case 'h':
				help();
				return 0;
			case 'o':
				output = argv[i] + 1;
				break;
			}
		} else {
			/* A file has been specified! */
			if ((unsigned)j < BFS_NODE_COUNT) {
				name = strchr(argv[i], '=');

				if (name == NULL) {
					fprintf(stderr, "error: Malformed file specifier '%s'. (no '=' found)\n", argv[i]);
					return EXIT_FAILURE;
				}

				if (name - argv[i] > BFS_NAME_LENGTH) {
					fprintf(stderr, "error: BFS file name cannot exceed %d characters.\n", BFS_NAME_LENGTH);
					return EXIT_FAILURE;
				}

				files[j] = name + 1;
				memcpy(nodes[j].name, argv[i], name - argv[i]);
				nodes[j].block_offset = offset;
				nodes[j].block_count  = count_blocks(files[j]);
				offset += nodes[j].block_count;
				j++;
			} else {
				fprintf(stderr, "error: Too many files to write! (max is %lu)\n", BFS_NODE_COUNT);
				return EXIT_FAILURE;
			}
		}
	}

	/* modify offsets */
	for (i = 0; i < j; i++) {
		nodes[i].block_offset += start_block;
	}

	/* write the bfs system */
	f = fopen(output, "wb");
	if (f == NULL) {
		fprintf(stderr, "error: Could not open '%s' for writing.\n", output);
		return EXIT_FAILURE;
	}

	for (i = 0; i < j; i++) {
		fseek(f, nodes[i].block_offset * BFS_BLOCK_SIZE, SEEK_SET);

		if (strcmp(files[i], SUPERBLOCK_NAME)) {
			write_file(files[i], f);
		} else {
			fwrite(nodes, BFS_BLOCK_SIZE, 1, f);
			wrotesb = 1;
		}
	}

	fclose(f);

	/* check that we wrote the superblock */
	if (!wrotesb) {
		fprintf(stderr, "warning: Superblock never written!\n");
	}

	return 0;
}
