from prefect.blocks.system import Secret

secret_block = Secret(value="abcd1234")
secret_block.save(name="necromancer", overwrite=True)
