import knex from '../db/knex.js';

const TABLE_NAME = 'users';

export const User = {
  async create({ email, password, name, phone }) {
    const [user] = await knex(TABLE_NAME).insert({
      email,
      password,
      name,
      phone,
      created_at: new Date(),
      updated_at: new Date()
    }).returning('*');
    return user;
  },

  async findById(id) {
    return knex(TABLE_NAME).where({ id }).first();
  },

  async findByEmail(email) {
    return knex(TABLE_NAME).where({ email }).first();
  },

  async update(id, data) {
    const [user] = await knex(TABLE_NAME)
      .where({ id })
      .update({ ...data, updated_at: new Date() })
      .returning('*');
    return user;
  },

  async delete(id) {
    return knex(TABLE_NAME).where({ id }).del();
  },

  async search(query, limit = 20) {
    return knex(TABLE_NAME)
      .where('name', 'ilike', `%${query}%`)
      .orWhere('email', 'ilike', `%${query}%`)
      .limit(limit);
  }
};

export default User;
