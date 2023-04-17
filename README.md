# YUL EXAMPLE

This project demonstrates inline assembly and yul implementations of several common contracts

## Gas comparison

### AssemblyERC20

| Methods       |              |       |       |        |
| ------------- | ------------ | ----- | ----- | ------ |
| Contract      | Method       | Min   | Max   | Avg    |
| AssemblyERC20 | approve      | 22298 | 44282 | 34511  |
| AssemblyERC20 | burn         | 27436 | 34294 | 30865  |
| AssemblyERC20 | mint         | 34290 | 68490 | 61650  |
| AssemblyERC20 | transfer     | 27461 | 49349 | 36353  |
| AssemblyERC20 | transferFrom | 30361 | 55039 | 41113  |
| StandardERC20 | approve      | 24260 | 46244 | 36473  |
| StandardERC20 | burn         | 28979 | 36223 | 32601  |
| StandardERC20 | mint         | 36183 | 70383 | 63543  |
| StandardERC20 | transfer     | 29496 | 51384 | 38388  |
| StandardERC20 | transferFrom | 33617 | 59109 | 44912  |

| Deployments   | Gas    |
| ------------- | ------ |
| AssemblyERC20 | 508781 |
| StandardERC20 | 731427 |
