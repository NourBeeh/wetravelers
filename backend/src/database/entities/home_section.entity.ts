import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('home_sections')
export class HomeSection {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column()
  title!: string;

  @Column({ nullable: true })
  subtitle?: string;

  @Column()
  layout!: string;

  @Column({ type: 'int' })
  order!: number;

  @Column({ default: true })
  isVisible!: boolean;

  @Column({ nullable: true })
  expiresAt?: Date;

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt!: Date;
}
